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
local file_name = '/usr/local/tengine/logs/mapi.ipaylinks.com.audit.log'

function write_content(fileName, content)
        local  f = assert(io.open(fileName,'a'))
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


local extend = string.format('srcip=%s&x_srcip=%s&time="%s"&server=%s&server_ip=%s&method=%s&link="%s://%s%s&status=%s&referer="%s"&post="%s"&user_agent="%s"',ngx.var.remote_addr,ngx.var.http_x_forwarded_for,ngx.var.time_local,ngx.var.server_name,ngx.var.server_addr,ngx.var.request_method,ngx.var.scheme,ngx.var.host,ngx.var.request_uri,ngx.var.status,ngx.var.referer,handle_body(ngx.var.request_body),ngx.var.http_user_agent)

if(ngx.req.get_method() == 'POST')
then
    write_content(file_name, extend..'\n')
end
```
#### 6.Lua加载顺序
![](https://cloud.githubusercontent.com/assets/2137369/15272097/77d1c09e-1a37-11e6-97ef-d9767035fc3e.png)
