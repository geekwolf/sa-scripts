#### 1. install softs

```
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.15.tar.gz
wget http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
wget https://github.com/simplresty/ngx_devel_kit/archive/v0.3.1.tar.gz
wget https://openresty.org/download/openresty-1.15.8.1.tar.gz
```
#### 2. install openrestry luajit2 lib
```
./configure --prefix=/user/local/openresty-1.15.8.1
make 
make install
ln -s /usr/local/openresty-1.15.8.1/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
export LUAJIT_LIB=/usr/local/openresty-1.15.8.1/luajit/lib/
export LUAJIT_INC=/usr/local/openresty-1.15.8.1/luajit/include/luajit-2.1/

```
#### 3. install tengine

```
./configure --prefix=/usr/local/tengine/ --with-http_gzip_static_module --add-module=/data/data/softs/lua-nginx-module-0.10.15/ --add-module=/data/data/softs/ngx_devel_kit-0.3.1/
make
make install
```

#### 4. Nginx Configure: log_by_lua_file
```
log_by_lua_file /usr/local/tengine/conf/lua/ngx_log.lua;
```

### 5. ngx_log.lua
```


-- local file_name

-- if ngx.var.file_type == 'audit' then
--    file_name = '/usr/local/apps/nginx/logs/audit.log'
-- elseif ngx.var.file_type == 'mapi'then
--     file_name = '/usr/local/apps/nginx/logs/access.log'
-- end


local file_audit = '/usr/local/apps/nginx/logs/audit.log'
local file_mapi  = '/usr/local/apps/nginx/logs/access.log'


function write_content(file_name, content)
        local  f = assert(io.open(file_name,'a'))
        f:write(content)
        f:close()
end

function urlDecode(s)
    if(nil ~= s)
    then  
        s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)  
        return s  
    end
end  

function handle_body(s)
    s = urlDecode(s)
    if(nil ~= s)
    then
        return string.gsub(s,'payMethodInfo=(.-)&','payMethodInfo=***&')
    end
end


local remote_addr = ngx.var.remote_addr
local http_x_forwarded_for = ngx.var.http_x_forwarded_for
local time_local = ngx.var.time_local
local server_name = ngx.var.server_name
local request_method = ngx.var.request_method
local scheme = ngx.var.scheme
local host = ngx.var.host
local request_uri = ngx.var.request_uri
local status = ngx.var.status
local referer = ngx.var.referer
local body = handle_body(ngx.var.request_body)
local http_user_agent = ngx.var.http_user_agent
local upstream_status = ngx.var.upstream_status
local request_time = ngx.var.request_time
local upstream_response_time = ngx.var.upstream_response_time
local http_host = ngx.var.http_host
local scheme_http_host_request_uri = ngx.var.scheme..'://'..http_host..request_uri
local body_bytes_sent = ngx.var.body_bytes_sent
local http_referer = ngx.var.http_referer
local upstream_addr = ngx.var.upstream_addr



-- if ngx.var.file_type == 'audit' then
--     local extend = string.format('srcip=%s&x_srcip=%s&time="%s"&server=%s&server_ip=%s&method=%s&link="%s://%s%s&status=%s&referer="%s"&post="%s"&user_agent="%s"',remote_addr,http_x_forwarded_for,time_local,server_name,server_addr,request_method,scheme,host,request_uri,status,referer,body,http_user_agent)
--     if(ngx.req.get_method() == 'POST')
--     then
--         write_content(file_audit, extend..'\n')
--     end
-- elseif ngx.var.file_type == 'mapi' then
--     local extend = string.format('{"upstream_status":%s,"request_time":%s,"upstream_response_time":%s,"remote_addr":%s,"time_local":%s,"scheme_http_host_request_uri":%s,"status":%s,"body_bytes_sent":%s,"http_referer":%s,"request_body":%s,"http_user_agent":%s,"http_x_forwarded_for":%s,"upstream_addr":%s}',upstream_status,request_time,upstream_response_time,remote_addr,time_local,scheme_http_host_request_uri,status,body_bytes_sent,http_referer,request_body,http_user_agent,http_x_forwarded_for,upstream_addr)
--     write_content(file_mapi, extend..'\n')
-- end

local extend_audit = string.format('srcip=%s&x_srcip=%s&time="%s"&server=%s&server_ip=%s&method=%s&link="%s://%s%s&status=%s&referer="%s"&post="%s"&user_agent="%s"',remote_addr,http_x_forwarded_for,time_local,server_name,server_addr,request_method,scheme,host,request_uri,status,referer,body,http_user_agent)
local extend_mapi = string.format('{"upstream_status":%s,"request_time":%s,"upstream_response_time":%s,"remote_addr":%s,"time_local":%s,"scheme_http_host_request_uri":%s,"status":%s,"body_bytes_sent":%s,"http_referer":%s,"request_body":%s,"http_user_agent":%s,"http_x_forwarded_for":%s,"upstream_addr":%s}',upstream_status,request_time,upstream_response_time,remote_addr,time_local,scheme_http_host_request_uri,status,body_bytes_sent,http_referer,request_body,http_user_agent,http_x_forwarded_for,upstream_addr)

if(ngx.req.get_method() == 'POST')
then
    write_content(file_audit, extend_audit..'\n')
end
write_content(file_mapi, extend_mapi..'\n')

```
#### 6.Lua加载顺序
![](https://cloud.githubusercontent.com/assets/2137369/15272097/77d1c09e-1a37-11e6-97ef-d9767035fc3e.png)
