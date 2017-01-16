#!/bin/bash
# Copyright (c) 2010, Yu-Jie Lin
# All rights reserved. https://github.com/livibetter/bash-oauth
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

OAuth_debug () {
	# Print out all parameters, each in own line
	[[ "$OAUTH_DEBUG" == "" ]] && return
	local t=$(date +%FT%T.%N)
	while (( $# > 0 )); do
		echo "[OAuth][DEBUG][$t] $1"
		shift 1
		done
	}

OAuth_nonce () {
	# Return a nonce
	md5sum <<< "$RANDOM-$(date +%s.%N)" | cut -d' ' -f 1
	}

OAuth_timestamp () {
	# Return timestamp
	echo "$(date +%s)"
	}

OAuth_PE () {
	# Encode $1 using Percent-encoding as defined in
	# http://tools.ietf.org/html/rfc5849#section-3.6
	# Any character other than [a-zA-Z0-9-._~] is converted into format %XX
    [ -n "$1" ] \
	&& echo -n "$1" | perl -p -e 's/([^A-Za-z0-9-._~])/sprintf("%%%02X", ord($1))/seg'
}

OAuth_PE_file () {
	# Encode a file $1 using Percent-encoding as defined in
	# http://tools.ietf.org/html/rfc5849#section-3.6
	# $1 a filename, not the content of file
    perl -p -e 's/([^A-Za-z0-9-._~])/sprintf("%%%02X", ord($1))/seg' < "$1"
}

OAuth_params_string () {
	# Sort the paramters and join them into one-line string
	while (( $# > 0 )); do
		echo $1
		shift 1
		done | sort | tr '\n' '&' | sed 's/&$//'
	}

OAuth_base_string () {
	# $1 method: "GET", "POST", etc
	# $2 url
	# $3-$N params
	local method=$1
	local url=$2
	shift 2

	local params_string=$(OAuth_params_string $@)

	echo "$method&$(OAuth_PE "$url")&$(OAuth_PE "$params_string")"
	}

OAuth_param () {
	# Return a percent encoded key-value pair
	# $1 key
	# $2 value
	echo "$(OAuth_PE "$1")=$(OAuth_PE "$2")"
	}

OAuth_param_quote () {
	# Return a percent encoded key-value pair, value is quoted
	# $1 key
	# $2 value
	echo "$(OAuth_PE "$1")=\"$(OAuth_PE "$2")\""
	}

OAuth_param_file () {
	# Return a percent encoded key-value pair, the value is an encoded file content
	# $1 key
	# $2 filename
	echo "$(OAuth_PE "$1")=$(OAuth_PE_file "$2")"
	}

OAuth_param_raw_value () {
	# Return a percent encoded key-value pair, only key will be encoded by this function
	# $1 key
	# $2 value
	echo "$(OAuth_PE "$1")=$2"
	}

OAuth_HMAC_SHA1 () {
	# Hash the text $1 with key $2
    local text="$1"
	local key="$2"
    echo -n "$text" | openssl dgst -sha1 -binary -hmac "$key" | base64
	}

_OAuth_signature () {
	# Return the signature, note it's necessary to pass to OAuth_PE before add to header
	# $1 signature_method
	# $2 base_string
	# $3 consumer_secret
	# $4 token_secret
	local signature_method="OAuth_${1//-/_}"
	local base_string=$2
	local c_secret=$3
	local t_secret=$4
	$signature_method "$base_string" "$c_secret&$t_secret"
	}

OAuth_signature () {
	# Return the signature, note it's necessary to pass to OAuth_PE before add to header
	# $1 base_string
	_OAuth_signature "$oauth_signature_method" "$1" "$oauth_consumer_secret" "$oauth_token_secret"
	}

_OAuth_authorization_header_params_string () {
	while (( $# > 0 )); do
		echo -n "$(cut -d\= -f 1 <<< "$1")=\"$(cut -d\= -f 2 <<< "$1")\""
		shift 1
		# Use break to prevent error code being returned
		(( $# > 0 )) && echo -n ', ' || break
		done
	}

_OAuth_authorization_header () {
	# Return header string
	# $1 header key
	# $2 OAuth realm, can be empty string
	# $3 OAuth consumer key
	# $4 OAuth consumer secret
	# $5 OAuth token
	# $6 OAuth token secret
	# $7 OAuth signature method
	# $8 OAuth version
	# $9 nonce
	# $10 timestamp
	# $11 method
	# $12 url
	# $13-$N params
	echo -n "$1: OAuth "
	[[ "$2" != "" ]] && echo -n "realm=\"$2\", "
	local oauth_consumer_key="$3"
	local oauth_consumer_secret="$4"
	local oauth_token="$5"
	local oauth_token_secret="$6"
	local oauth_signature_method="$7"
	local oauth_version="$8"
	local oauth_nonce="$9"
	[[ "$oauth_nonce" == "" ]] && oauth_nonce="$(OAuth_nonce)" 
	local oauth_timestamp="${10}"
	[[ "$oauth_timestamp" == "" ]] && oauth_timestamp="$(OAuth_timestamp)" 
	local method="${11}"
	local url="${12}"
	shift 12
	local params=(
		$(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
		$(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
		$(OAuth_param 'oauth_version' "$oauth_version")
		$(OAuth_param 'oauth_nonce' "$oauth_nonce")
		$(OAuth_param 'oauth_timestamp' "$oauth_timestamp")
		)
	[[ "$oauth_token" != "" ]] && params[${#params[@]}]=$(OAuth_param 'oauth_token' "$oauth_token")
	local sign_params=${params[@]}
	while (( $# > 0 )); do
		sign_params[${#sign_params[@]}]="$1"
		shift 1
		done
	local base_string=$(OAuth_base_string "$method" "$url" ${sign_params[@]})
	local signature=$(_OAuth_signature "$oauth_signature_method" "$base_string" "$oauth_consumer_secret" "$oauth_token_secret")
	params[${#params[@]}]=$(OAuth_param 'oauth_signature' "$signature")
	_OAuth_authorization_header_params_string ${params[@]}
	}

OAuth_authorization_header () {
	# Return header string
	# $1 header key
	# $2 OAuth realm, can be empty string
	# $3 OAuth nonce
	# $4 OAuth timestamp
	# $5 method
	# $6 url
	# $7-$N params
	local header_key="$1"
	local realm="$2"
	local oauth_nonce="$3"
	local oauth_timestamp="$4"
	local method="$5"
	local url="$6"
	shift 6
	local params=()
	while (( $# > 0 )); do
		params[${#params[@]}]="$1"
		shift 1
		done
	_OAuth_authorization_header "$header_key" "$realm" "$oauth_consumer_key" "$oauth_consumer_secret" "$oauth_token" "$oauth_token_secret" "$oauth_signature_method" "$oauth_version" "$oauth_nonce" "$oauth_timestamp" "$method" "$url" ${params[@]}
	}
