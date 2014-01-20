#!/bin/bash

#load oauth source
source OAuth.sh

#Set to 1 to enable DEBUG mode
DEBUG=0

#Set to 1 to enable VERBOSE mode
VERBOSE=1

#Default configuration file
CONFIG_FILE=~/.kuaipan_uploader

#Don't edit these...
API_REQUEST_TOKEN_URL="https://openapi.kuaipan.cn/open/requestToken"
API_USER_AUTH_URL="https://www.kuaipan.cn/api.php?ac=open&op=authorise"
API_ACCESS_TOKEN_URL="https://openapi.kuaipan.cn/open/accessToken"
API_LOCATE_URL="http://api-content.dfs.kuaipan.cn/1/fileops/upload_locate"
API_UPLOAD_URL="1/fileops/upload_file"
APP_CREATE_URL="http://www.kuaipan.cn/developers/create.htm"
RESPONSE_FILE="/tmp/du_resp_$RANDOM"
BIN_DEPS="curl sed"
VERSION="0.1"

OAUTH_VERSION="1.0"
SIGNATURE_METHOD="HMAC-SHA1"
KUAIPAN_PATH="backup/"

umask 077

if [ $DEBUG -ne 0 ]; then
    set -x
    RESPONSE_FILE="/tmp/du_resp_debug"
fi


#Remove temporary files
function remove_temp_files
{
    if [ $DEBUG -eq 0 ]; then
        rm -fr $RESPONSE_FILE
    fi
}

#Replace spaces
function urlencode
{
    str=$1
    echo ${str// /%20}
}

#USAGE
function usage() {
    echo -e "快盘上传shell脚本 v$VERSION"
    echo -e "1号蟋蟀 - come.a.mail@gmail.com\n"
    echo -e "使用: $0 命令 [参数]..."
    echo -e "\n命令:"
    echo -e "\t upload [源文件]"    
    echo -en "\n"
    remove_temp_files
    exit 1
}

#CHECK DEPENDENCIES
for i in $BIN_DEPS; do
    which $i > /dev/null
    if [ $? -ne 0 ]; then
        echo -e "错误: 文件未找到:  $i"
        remove_temp_files
        exit 1
    fi
done

#CHECKING FOR AUTH FILE
if [ -f $CONFIG_FILE ]; then
      
    #Loading data...
    CONSUMER_KEY=$(sed -n -e 's/CONSUMER_KEY:\([a-z A-Z 0-9]*\)/\1/p' $CONFIG_FILE)
    CONSUMER_SECRET=$(sed -n -e 's/CONSUMER_SECRET:\([a-z A-Z 0-9]*\)/\1/p' $CONFIG_FILE)   
    OAUTH_ACCESS_TOKEN=$(sed -n -e 's/OAUTH_ACCESS_TOKEN:\([a-z A-Z 0-9]*\)/\1/p' $CONFIG_FILE)
    OAUTH_ACCESS_TOKEN_SECRET=$(sed -n -e 's/OAUTH_ACCESS_TOKEN_SECRET:\([a-z A-Z 0-9]*\)/\1/p' $CONFIG_FILE)
    
#NEW SETUP...
else

    echo -ne "\n这是你第一次运行此脚本\n"    
    echo -ne "如果你尚未创建任何快盘应用,请先创建一个,快盘系统会给你的应用分配<consumer_key>和<consumer_secret>\n"
    echo -ne "创建快盘应用的时候,请设置 <访问权限> 为 '整个快盘' \n\n"
    echo -ne "当你成功创建完应用以后,请输入以下信息: \n\n"
    #Getting the app key and secret from the user
    while (true); do
        
        echo -n " # consumer_key: "
        read CONSUMER_KEY

        echo -n " # consumer_secret: "
        read CONSUMER_SECRET

        echo -ne " > consumer_key 是 $CONSUMER_KEY, consumer_secret  是 $CONSUMER_SECRET, 正确? [y/n]"
        read answer
        if [ "$answer" == "y" ]; then
            break;
        fi

    done

    #TOKEN REQUESTS
    echo -ne "\n > 获取授权第一步: request token... "
    OAUTH_TIMESTAMP="$(OAuth_timestamp)"
    OAUTH_NONCE="$(OAuth_nonce)"
    params=(
               $(OAuth_param 'oauth_consumer_key' "$CONSUMER_KEY")
               $(OAuth_param 'oauth_signature_method' "$SIGNATURE_METHOD")
               $(OAuth_param 'oauth_version' "$OAUTH_VERSION")
               $(OAuth_param 'oauth_nonce' "$OAUTH_NONCE")
               $(OAuth_param 'oauth_timestamp' "$OAUTH_TIMESTAMP")
           )

    BASE_STRING=$(OAuth_base_string 'GET' "$API_REQUEST_TOKEN_URL" ${params[@]})
    
    SIGNATURE=$(_OAuth_signature "$SIGNATURE_METHOD" "$BASE_STRING" "$CONSUMER_SECRET" "")
            
    curl -k -s --show-error -i -o $RESPONSE_FILE "$API_REQUEST_TOKEN_URL?oauth_version=$OAUTH_VERSION&oauth_consumer_key=$CONSUMER_KEY&oauth_signature_method=$SIGNATURE_METHOD&oauth_signature=$SIGNATURE&oauth_timestamp=$OAUTH_TIMESTAMP&oauth_nonce=$OAUTH_NONCE"
    OAUTH_TOKEN_SECRET=$(sed -n -e 's/{"oauth_token_secret": "\([a-z A-Z 0-9]*\).*/\1/p' "$RESPONSE_FILE")
    OAUTH_TOKEN=$(sed -n -e 's/.*oauth_token": "\([a-zA-Z0-9]*\)", ".*}/\1/p' "$RESPONSE_FILE")


    if [ "$OAUTH_TOKEN" != "" -a "$OAUTH_TOKEN_SECRET" != "" ]; then
        echo -ne " 第一步成功\n"
    else
        cat $RESPONSE_FILE
        echo -ne "\n"
        echo -ne " 获取request token失败\n\n 请确认你的consumer_key以及cosumer_secret的正确性...\n\n"
        remove_temp_files
        exit 1
    fi

    while (true); do

        #USER AUTH
        echo -ne "\n > 获取授权第二步: 请使用浏览器打开这个URL,并授权该脚本访问你的快盘--> ${API_USER_AUTH_URL}&oauth_token=$OAUTH_TOKEN\n"
        echo -ne "\n 完成以后,请按<回车>键...\n"
        read
        
        echo -n " # 授权码: "
        read OAUTH_VERIFIER

        #API_ACCESS_TOKEN_URL
        echo -ne " > 最后: 正在获取授权... "
        
        OAUTH_TIMESTAMP="$(OAuth_timestamp)"
        OAUTH_NONCE="$(OAuth_nonce)"
        params=(
                   $(OAuth_param 'oauth_consumer_key' "$CONSUMER_KEY")
                   $(OAuth_param 'oauth_signature_method' "$SIGNATURE_METHOD")
                   $(OAuth_param 'oauth_version' "$OAUTH_VERSION")
                   $(OAuth_param 'oauth_nonce' "$OAUTH_NONCE")
                   $(OAuth_param 'oauth_timestamp' "$OAUTH_TIMESTAMP")               
                   $(OAuth_param 'oauth_verifier' "$OAUTH_VERIFIER")
                   $(OAuth_param 'oauth_token' "$OAUTH_TOKEN")
               )

        BASE_STRING=$(OAuth_base_string 'GET' "$API_ACCESS_TOKEN_URL" ${params[@]})
        SIGNATURE=$(_OAuth_signature "$SIGNATURE_METHOD" "$BASE_STRING" "$CONSUMER_SECRET" "$OAUTH_TOKEN_SECRET")
        
        curl -k -s --show-error -i -o $RESPONSE_FILE "$API_ACCESS_TOKEN_URL?oauth_version=$OAUTH_VERSION&oauth_consumer_key=$CONSUMER_KEY&oauth_token=$OAUTH_TOKEN&oauth_signature_method=$SIGNATURE_METHOD&oauth_signature=$SIGNATURE&oauth_timestamp=$OAUTH_TIMESTAMP&oauth_nonce=$OAUTH_NONCE&oauth_verifier=$OAUTH_VERIFIER"
        OAUTH_ACCESS_TOKEN_SECRET=$(sed -n -e 's/{"oauth_token_secret": "\([a-z A-Z 0-9]*\).*/\1/p' "$RESPONSE_FILE")
        OAUTH_ACCESS_TOKEN=$(sed -n -e 's/.*oauth_token": "\([a-zA-Z0-9]*\)", ".*}/\1/p' "$RESPONSE_FILE")
        OAUTH_ACCESS_USER_ID=$(sed -n -e 's/.*user_id": \([0-9]*\), ".*}/\1/p' "$RESPONSE_FILE")
        
        if [ "$OAUTH_ACCESS_TOKEN" != "" -a "$OAUTH_ACCESS_TOKEN_SECRET" != "" -a "$OAUTH_ACCESS_USER_ID" != "" ]; then
            echo -ne "获取授权成功,请重新运行该脚本,开始使用！\n"
            
            #Saving data
            echo "CONSUMER_KEY:$CONSUMER_KEY" > $CONFIG_FILE
            echo "CONSUMER_SECRET:$CONSUMER_SECRET" >> $CONFIG_FILE
            echo "OAUTH_ACCESS_TOKEN:$OAUTH_ACCESS_TOKEN" >> $CONFIG_FILE
            echo "OAUTH_ACCESS_TOKEN_SECRET:$OAUTH_ACCESS_TOKEN_SECRET" >> $CONFIG_FILE
            
            echo -ne "\n 授权设置完成,请重新运行脚本开始使用!\n"
            break
        else
            cat $RESPONSE_FILE
            printf "获取授权失败,请重试！\n"
        fi

    done;
    
    remove_temp_files     
    exit 0
fi

COMMAND=$1

#CHECKING PARAMS VALUES
case $COMMAND in

upload)

    FILE_SRC=$2
    FILE_DST=$(urlencode "$3")

    #Checking FILE_SRC
    if [ ! -f "$FILE_SRC" ]; then
        echo -e "请指定一个有效的本地文件!"
        remove_temp_files
        exit 1
    fi
    
    #Checking FILE_DST
    if [ -z "$FILE_DST" ]; then
        FILE_DST=$(basename "$FILE_SRC")
    fi    
    
    ;;
        
*)
    usage
    ;;
esac

################
#### START  ####
################

#COMMAND EXECUTION
case "$COMMAND" in

    upload)
        printf " > 获取上传地址... \n" 
        OAUTH_TIMESTAMP="$(OAuth_timestamp)"
        OAUTH_NONCE="$(OAuth_nonce)"
        params=(
                   $(OAuth_param 'oauth_consumer_key' "$CONSUMER_KEY")
                   $(OAuth_param 'oauth_signature_method' "$SIGNATURE_METHOD")
                   $(OAuth_param 'oauth_version' "$OAUTH_VERSION")
                   $(OAuth_param 'oauth_nonce' "$OAUTH_NONCE")
                   $(OAuth_param 'oauth_timestamp' "$OAUTH_TIMESTAMP")               
                   $(OAuth_param 'oauth_verifier' "$OAUTH_VERIFIER")
                   $(OAuth_param 'oauth_token' "$OAUTH_TOKEN")
               )

        BASE_STRING=$(OAuth_base_string 'GET' "$API_ACCESS_TOKEN_URL" ${params[@]})
        SIGNATURE=$(_OAuth_signature "$SIGNATURE_METHOD" "$BASE_STRING" "$CONSUMER_SECRET" "$OAUTH_TOKEN_SECRET")
        
        curl -k -s --show-error -i -o $RESPONSE_FILE "$API_LOCATE_URL?oauth_version=$OAUTH_VERSION&oauth_consumer_key=$CONSUMER_KEY&oauth_signature_method=$SIGNATURE_METHOD&oauth_signature=$SIGNATURE&oauth_timestamp=$OAUTH_TIMESTAMP&oauth_nonce=$OAUTH_NONCE&oauth_token=$OAUTH_ACCESS_TOKEN"
        
        GOT_UPLOAD_URL=$(sed -n -e 's/.*url": "\(.*\)", ".*}/\1/p' "$RESPONSE_FILE")        
        
        if [ -z "$GOT_UPLOAD_URL" ]; then            
            cat $RESPONSE_FILE
            echo -ne "获取获取上传地址失败！\n"
        else
            echo -ne " > 正在上传 $FILE_SRC 至 $KUAIPAN_PATH  ... \n"  
            OAUTH_TIMESTAMP="$(OAuth_timestamp)"
            OAUTH_NONCE="$(OAuth_nonce)"
            UPLOAD_PATH="$KUAIPAN_PATH$FILE_DST"
            UPLOAD_ROOT="app_folder"
            UPLOAD_OVERWRITE="true"
            UPLOAD_FULL_URL="$GOT_UPLOAD_URL$API_UPLOAD_URL"
            params=(
                       $(OAuth_param 'oauth_consumer_key' "$CONSUMER_KEY")
                       $(OAuth_param 'oauth_signature_method' "$SIGNATURE_METHOD")
                       $(OAuth_param 'oauth_version' "$OAUTH_VERSION")
                       $(OAuth_param 'oauth_nonce' "$OAUTH_NONCE")
                       $(OAuth_param 'oauth_timestamp' "$OAUTH_TIMESTAMP")               
                       $(OAuth_param 'oauth_token' "$OAUTH_ACCESS_TOKEN")
                       $(OAuth_param 'root' "$UPLOAD_ROOT")
                       $(OAuth_param 'overwrite' "$UPLOAD_OVERWRITE")
                       $(OAuth_param 'path' "$UPLOAD_PATH")
                   )

            BASE_STRING=$(OAuth_base_string 'POST' "$UPLOAD_FULL_URL" ${params[@]})
            SIGNATURE=$(_OAuth_signature "$SIGNATURE_METHOD" "$BASE_STRING" "$CONSUMER_SECRET" "$OAUTH_ACCESS_TOKEN_SECRET")
            
            curl --progress-bar -k -i -o "$RESPONSE_FILE" -F "file=@$FILE_SRC" "$UPLOAD_FULL_URL?oauth_consumer_key=$CONSUMER_KEY&oauth_token=$OAUTH_ACCESS_TOKEN&oauth_signature_method=$SIGNATURE_METHOD&oauth_signature=$SIGNATURE&oauth_timestamp=$OAUTH_TIMESTAMP&oauth_nonce=$OAUTH_NONCE&oauth_version=$OAUTH_VERSION&root=$UPLOAD_ROOT&overwrite=$UPLOAD_OVERWRITE&path=$UPLOAD_PATH"
            #Check
            grep "HTTP/1.1 200 OK" "$RESPONSE_FILE" > /dev/null
            if [ $? -eq 0 ]; then
                printf " >上传完成！<\n"
            else
                cat $RESPONSE_FILE
                printf " >上传失败！<\n"
            fi
        fi
        ;;
                
    *)
        usage
        ;;
        
esac

remove_temp_files

