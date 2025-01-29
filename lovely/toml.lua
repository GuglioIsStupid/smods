
-- TOML parser
-- by MineRobber___T/khuxkm
-- no guarantee it'll pass every test but it should absolutely be capable
-- of reading valid TOML passed to it
--
-- returns a parse function; TOML goes in, table comes out
--
-- MIT licensed

local function lookupify(a,b)
    b=b or {}
    if type(a)=="string" then
        local x={}
        for i=1,#a do
            x[#x+1]=a:sub(i,i)
        end
        a=x
    end
    local ret = {}
    for k,v in pairs(b) do
        ret[k]=v
    end
    local i=1
    while a[i] do
        ret[a[i]]=true
        i=i+1
    end
    return ret
end

local function rangedstr(s)
    return (s:gsub("(.)-(.)",function(s,e)
        if s=="\\" then
            return s.."-"..e
        end
        local s1=s:byte()
        local e1=e:byte()
        local r=""
        for i=s1,e1,1 do
            r=r..string.char(i)
        end
        return r
    end))
end

local whitespace=lookupify(" \t")
local bare_key_chars=lookupify(rangedstr("A-Za-z0-9_-"))
local key_start_chars=lookupify('"'.."'",bare_key_chars)
local non_decimal_bases={x={p="[0-9A-Fa-f]+",b=16},b={p="[01]+",b=2},o={p="[0-7]+",b=8}}
local integer_pattern="[+-]?%d+"
local decimal_digits=lookupify(rangedstr("0-9"))
local integer_allowed_chars=lookupify("_",decimal_digits)
local date_pattern="(%d%d%d%d)%-(%d%d)%-(%d%d)"
local date_time_separator="[ Tt]"
local partial_time="(%d%d):(%d%d):(%d%d)"
local time_frac=".%d+"
local time_offset_start=lookupify("+-Z")
local time_offset_pattern="([+-])(%d%d):(%d%d)"

local function skip_whitespace(src,pos,newline)
    while whitespace[src:sub(pos,pos)] do pos=pos+1 end
    if newline and src:sub(pos,pos)=="\n" then return skip_whitespace(src,pos+1,true) end
    return pos
end

local function bstr(src,pos) -- basic string
    assert(src:sub(pos,pos)=='"',"invalid state for string parse")
    local ret=""
    pos=pos+1
    while src:sub(pos,pos)~='"' do
        if src:sub(pos,pos)=="\\" then
            pos=pos+1
            if src:sub(pos,pos)=="b" then
                ret=ret.."\x08"
                pos=pos+1
            elseif src:sub(pos,pos)=="t" then
                ret=ret.."\x09"
                pos=pos+1
            elseif src:sub(pos,pos)=="n" then
                ret=ret.."\x0A"
                pos=pos+1
            elseif src:sub(pos,pos)=="f" then
                ret=ret.."\x0C"
                pos=pos+1
            elseif src:sub(pos,pos)=="r" then
                ret=ret.."\x0D"
                pos=pos+1
            elseif src:sub(pos,pos)=='"' then
                ret=ret..'"'
                pos=pos+1
            elseif src:sub(pos,pos)=="\\" then
                ret=ret.."\\"
                pos=pos+1
            elseif src:sub(pos,pos)=="u" then
                pos=pos+1
                local start,_end = src:find(("[0-9A-Fa-f]"):rep(4),pos)
                if not start then error("invalid unicode escape \\u"..src:sub(pos,pos+4)) end
                ret=ret..utf8.char(tonumber(src:sub(start,_end),16))
                pos=_end+1
            elseif src:sub(pos,pos)=="U" then
                pos=pos+1
                local start,_end = src:find(("[0-9A-Fa-f]"):rep(8),pos)
                if not start then error("invalid unicode escape \\U"..src:sub(pos,pos+8)) end
                ret=ret..utf8.char(tonumber(src:sub(start,_end),16))
                pos=_end+1
            else
                error("Invalid escape code "..src:sub(pos,pos))
            end
        else
            ret=ret..src:sub(pos,pos)
            pos=pos+1
        end
    end
    return pos+1,ret
end

local function mbstr(src,pos)
    local s,e = src:find('""".-"""',pos)
    return e+1, (src:sub(s+3,e-3):gsub("\\([btnfr\"])",function(c)
        return ({['"']='"',b="\x08",t="\x09",n="\n",f="\x0c",r="\r"})[c]
    end):gsub("\\u([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])",function(n)
        return utf8.char(tonumber(n,16))
    end):gsub("\\U([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])",function(n)
        return utf8.char(tonumber(n,16))
    end):gsub("\\(.)",function(c)
        if c=="\\" then
            return "\\"
        end
        error("Invalid escape code \\"..c)
    end))
end

local function lstr(src,pos) -- literal strings
    local s,e = src:find("'.-'",pos)
    return e+1, src:sub(s+1,e-1)
end

local function mlstr(src,pos)
    local s,e = src:find("'''.-'''",pos)
    return e+1, src:sub(s+3,e-3)
end

local integer
local function float(src,pos)
    local pos, n = integer(src,pos,true)
    if src:sub(pos,pos)=="." then
        pos=pos+1
        local d="0."
        if n<0 then d="-"..d end
        while decimal_digits[src:sub(pos,pos)] do
            d=d..src:sub(pos,pos)
            pos=pos+1
        end
        n=n+tonumber(d)
    end
    if src:sub(pos,pos)=="E" or src:sub(pos,pos)=="e" then
        pos=pos+1
        local s
        n, s = math.abs(n), (n<0 and -1 or 0)
        local exp
        pos, exp = integer(src,pos,false,true)
        n = s*(n*(10^exp))
    end
    return pos,n
end

function integer(src,pos,asfloat,allowleadingzeroes)
    assert(src:find(integer_pattern),"invalid state for integer parse")
    local ogpos = pos*1
    local sgn = 1
    if src:sub(pos,pos)=="-" then
        sgn=-1
        pos=pos+1
    elseif src:sub(pos,pos)=="+" then
        pos=pos+1
    end
    local n = ""
    while integer_allowed_chars[src:sub(pos,pos)] do
        if src:sub(pos,pos)=="_" then
            pos=pos+1
            assert(integer_allowed_chars[src:sub(pos,pos)],"invalid integer")
        end
        n=n..src:sub(pos,pos)
        pos=pos+1
    end
    if (not allowleadingzeroes) and n:find("^0+[1-9]") then error("invalid integer") end
    if (not asfloat) and (src:sub(pos,pos)=="." or src:sub(pos,pos):upper()=="E") then -- actually a float and we got here by mistake
        return float(src,ogpos)
    end
    return pos,tonumber(n)*sgn
end

local function is_leap_year(y)
    return (y%4)==0 and (((y%100)~=0) or ((y%400)==0))
end

local datetime
local function date(src,pos)
    local s,e,y,m,d = src:find(date_pattern,pos)
    pos=e+1
    y=tonumber(y)
    m=tonumber(m)
    d=tonumber(d)
    if y==0 then error("invalid date") end
    if m==0 then error("invalid date") end
    if m>12 then error("invalid date") end
    if d==0 then error("invalid date") end
    if m==4 or m==6 or m==9 or m==11 then -- 30 days
        if d>30 then error("invalid date") end
    elseif m==2 then -- 28/29 days
        if d>(is_leap_year(y) and 29 or 28) then error("invalid date") end
    else -- 31 days
        if d>31 then error("invalid date") end
    end
    local ret = {year=y,month=m,day=d}
    if src:find(date_time_separator,pos)==pos then
        return datetime(src,pos,ret)
    end
    return pos, ret
end

local function time_offset(src,pos,ret)
    if src:sub(pos,pos)=="Z" then
        ret.tz=0
        return pos+1,ret
    end
    local s,e,sgn,h,m = src:find(time_offset_pattern)
    sgn=(sgn=="+" and 1 or -1)
    h=tonumber(h)
    if h>23 then error("invalid time offset") end
    m=tonumber(m)
    if m>59 then error("invalid time offset") end
    ret.tz = sgn*(h*60)*m
    pos=e+1
    return pos, ret
end

local function time(src,pos,offset)
    local s,e,h,m,s = src:find(partial_time,pos)
    pos=e+1
    h=tonumber(h)
    m=tonumber(m)
    s=tonumber(s)
    if h>=24 then error("invalid time") end
    if m>=60 then error("invalid time") end
    if s>60 then error("invalid time") end
    if src:find(time_frac,pos)==pos then
        local s,e = src:find(time_frac,pos)
        local d = src:sub(s,e)
        pos=e+1
        s=s+tonumber(d)
    end
    local ret = {hour=h,min=m,sec=s}
    if offset and time_offset_start[src:sub(pos,pos)] then
        return time_offset(src,pos,ret)
    end
    return pos, ret
end

function datetime(src,pos,ret)
    pos=pos+1
    local time_obj
    pos, time_obj = time(src,pos,true)
    for k,v in pairs(time_obj) do
        ret[k]=v
    end
    return pos, ret
end

local function keypart(src,pos)
    assert(key_start_chars[src:sub(pos,pos)],"invalid state for key parse")
    if src:sub(pos,pos)=='"' then -- basic quoted key
        return bstr(src,pos)
    end
    if src:sub(pos,pos)=="'" then -- literal quoted key
        return lstr(src,pos)
    end
    -- bare key
    local ret=""
    while bare_key_chars[src:sub(pos,pos)] do
        ret=ret..src:sub(pos,pos)
        pos=pos+1
    end
    return pos,ret
end

local key_value_pair, parse
local function key(src,pos)
    local pos, ret = keypart(src,pos)
    ret = {ret}
    local ret2
    while src:sub(pos,pos)=="." do
        pos = skip_whitespace(src,pos+1)
        pos, ret2 = keypart(src,pos)
        ret[#ret+1]=ret2
        pos = skip_whitespace(src,pos)
    end
    return pos, ret
end

local traverse, immutableify, is_array
local function value(src,pos)
    pos = skip_whitespace(src,pos)
    if src:sub(pos,pos)=='"' then
        if src:sub(pos,pos+2)=='"""' then
            return mbstr(src,pos)
        end
        return bstr(src,pos)
    end
    if src:sub(pos,pos)=="'" then
        if src:sub(pos,pos+2)=="'''" then
            return mlstr(src,pos)
        end
        return lstr(src,pos)
    end
    if src:sub(pos,pos)=="0" and non_decimal_bases[src:sub(pos+1,pos+1)] then
        local base = non_decimal_bases[src:sub(pos+1,pos+1)]
        pos=pos+2
        local s,e = src:find(base.p,pos)
        if not s then error("invalid integer") end
        return e+1, tonumber(src:sub(s,e),base.b)
    end
    if src:find(date_pattern,pos)==pos then
        return date(src,pos)
    end
    if src:find(partial_time,pos)==pos then
        return time(src,pos)
    end
    if src:find(integer_pattern,pos)==pos then
        return integer(src,pos)
    end
    if src:find("true",pos)==pos or src:find("false",pos)==pos then
        if src:find("true",pos)==pos then
            return pos+4, true
        else
            return pos+5, false
        end
    end
    if src:sub(pos,pos)=="[" then
        local array = {}
        pos=skip_whitespace(src,pos+1,true)
        if src:sub(pos,pos)=="]" then
            return pos+1, array
        end
        pos, array[1] = value(src,pos)
        pos = skip_whitespace(src,pos,true)
        while src:sub(pos,pos)=="," and src:sub(skip_whitespace(src,pos+1,true)):sub(1,1)~="]" do
            pos, array[#array+1] = value(src,skip_whitespace(src,pos+1,true))
            pos = skip_whitespace(src,pos,true)
        end
        if src:sub(pos,pos)=="," then pos=skip_whitespace(src,pos+1,true) end
        assert(src:sub(pos,pos)=="]","unclosed array")
        return pos+1, array
    end
    if src:sub(pos,pos)=="{" then
        pos = skip_whitespace(src,pos+1)
        local inline_table = {}
        if src:sub(pos,pos)=="}" then
            immutableify(inline_table)
            return pos+1, inline_table
        end
        pos, k, v = key_value_pair(src,pos)
        pos = skip_whitespace(src, pos)
        if type(v)=="table" and not is_array(v) then
            immutableify(v)
        end
        local traversed = traverse(inline_table,k)
        traversed[k[#k]]=v
        while src:sub(pos,pos)=="," do
            pos = skip_whitespace(src,pos+1)
            pos, k, v = key_value_pair(src,pos)
            pos = skip_whitespace(src, pos)
            if type(v)=="table" and not is_array(v) then
                immutableify(v)
            end
            local traversed = traverse(inline_table,k)
            if traversed[k[#k]] then error('cannot redefine key') end
            traversed[k[#k]]=v
        end
        assert(src:sub(pos,pos)=="}","unclosed inline table")
        immutableify(inline_table)
        return skip_whitespace(src,pos+1), inline_table
    end
    print(src:sub(pos))
    error("cannot parse value at index "..pos)
end

local function skip_comment(src,pos)
    while src:sub(pos,pos)~="\n" do pos=pos+1 end
    return pos
end

function key_value_pair(src,pos)
    local k
    pos, k = key(src,pos)
    pos = skip_whitespace(src,pos)
    assert(src:sub(pos,pos)=="=","expected equals sign after key in key-value pair")
    pos=skip_whitespace(src,pos+1)
    local v
    pos, v = value(src,pos)
    return skip_whitespace(src,pos), k, v
end

local table__mt = {
    __add=function(v1,v2)
        local ret = setmetatable({},getmetatable(v1))
        for i=1,#v1 do
            ret[#ret+1]=v1[i]
        end
        for i=1,#v2 do
            ret[#ret+1]=v2[i]
        end
        return ret
    end,
    __eq=function(v1,v2)
        if #v1~=#v2 then return false end
        for i=1,#v1 do
            if v1[i]~=v2[i] then return false end
        end
        return true
    end
}

local immutable__mt = {
    __newindex=function(t,k) error("cannot modify immutable namespace") end
}

function immutableify(t)
    setmetatable(t,immutable__mt)
    for k,v in pairs(t) do
        if type(v)=="table" and getmetatable(v)~=immutable__mt then immutableify(v) end
    end
end

function is_array(t)
    local r=false
    for k,v in pairs(t) do
        r=true
        local tp = type(k)
        if tp~="integer" and tp~="number" then
            return false
        end
    end
    return r
end

function is_empty(t)
    for k,v in pairs(t) do return false end
    return true
end

function traverse(t,full_key)
    local traverse = t
    for i=1,(#full_key-1) do
        if not traverse[full_key[i]] then traverse[full_key[i]]={} end
        if type(traverse[full_key[i]])~="table" then error("cannot define table in already-defined non-table key") end
        traverse=traverse[full_key[i]]
    end
    return traverse
end

local function traverse_header(t,header)
    local traverse = t
    local k = {}
    for i=1,#header do
        k[#k+1]=header[i]
        if not traverse[header[i]] then traverse[header[i]]={} end
        if type(traverse[header[i]])~="table" then error("cannot define table in already-defined non-table key") end
        traverse=traverse[header[i]]
        if is_array(traverse) then
            k[#k+1]=#traverse
            traverse=traverse[#traverse]
        end
    end
    return k
end

function parse(src)
    src=src:gsub("\r\n","\n")
    local pos = 1
    local ret={}
    local header=setmetatable({},table__mt)
    local explicit_nest = {}
    while pos<=#src do
        if src:sub(pos,pos)=="#" then
            pos = skip_comment(src,pos)
        end
        if src:sub(pos,pos)=="\n" then
            pos = pos+1
        else
            if key_start_chars[src:sub(pos,pos)] then
                local k, v
                pos, k, v = key_value_pair(src,pos)
                k=setmetatable(k,table__mt)
                if type(v)=="table" and not is_array(v) then
                    immutableify(v)
                end
                local full_key = header+k
                local traversed = traverse(ret,full_key)
                if traversed[full_key[#full_key]] then error("cannot redefine key") end
                traversed[full_key[#full_key]]=v
            elseif src:sub(pos,pos)=="[" then
                if src:sub(pos+1,pos+1)=="[" then
                    pos = skip_whitespace(src,pos+2)
                    local h
                    pos, h = key(src,pos)
                    pos = skip_whitespace(src,pos)
                    header = setmetatable(traverse_header(ret,h),table__mt)
                    local trv
                    if type(header[#header])=="integer" or type(header[#header])=="number" then
                        header[#header]=nil -- remove integer
                    end
                    trv = traverse(ret,header)
                    if trv[header[#header]] and not (is_array(trv[header[#header]]) or is_empty(trv[header[#header]])) then error("cannot redefine key") end
                    trv[header[#header]]=trv[header[#header]] or {}
                    trv=trv[header[#header]]
                    trv[#trv+1]={}
                    header[#header+1]=#trv
                    assert(src:sub(pos,pos+1)=="]]","unclosed header line")
                    pos=skip_whitespace(src,pos+2)
                else
                    pos = skip_whitespace(src,pos+1)
                    local h
                    pos, h = key(src,pos)
                    pos = skip_whitespace(src,pos)
                    assert(src:sub(pos,pos)=="]","unclosed header line")
                    pos=pos+1
                    header = setmetatable(traverse_header(ret,h),table__mt)
                    for i=1,#explicit_nest do
                        if explicit_nest[i]==header then error("cannot declare key twice") end
                    end
                    explicit_nest[#explicit_nest+1]=header
                end
            end
            pos=skip_whitespace(src,pos)
            if src:sub(pos,pos)=="#" then pos=skip_comment(src,pos) end
            pos=pos+1
        end
    end
    return ret
end
return parse
