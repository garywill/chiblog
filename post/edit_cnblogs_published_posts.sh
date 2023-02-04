#!/bin/bash

script=$(readlink -f "$0")
scriptpath=$(dirname "$script")

CNBLOG_BLOG=garyw
ACCOUNT=garywill
PASSWD=E0CA5E37B4CCAFBB64DA0F08DCBD9AF89795E7B9625F8AC0B72A31055A8EFB22

LIST="
17167048|ESP32.md
14245886|lxd和虚拟X.md
14245882|ttffont.md
14245892|choose-linux-pc.md
13993831|百姓日用软件.md
13995826|程序员软件.md
12769303|在此打开终端.md
14068394|AndroidTV.md
12769392|BASH让标准输出和错误输出颜色不同.md
12769420|cgroup.md
12769265|distro.md
14245879|firefox_uc脚本.md
14004679|github6.md
12769264|Linux关联文件扩展名和打开程序.md
13832029|Linux-process-DNS.md
12769259|qr.md
13468491|wine.md
"

for line in $LIST  
do
    POST_ID=${line%|*}
    ARTI_FILE=${line#*|}
    
    cp $scriptpath/$ARTI_FILE /dev/shm/arti.esc.md

    # 取得头部hugo部分
    head_range="$(grep -E "^---[[:space:]]*$"  -n -h -m 2 /dev/shm/arti.esc.md | cut -d ':' -f 1)"
    head_1="$(echo $head_range | cut -d ' ' -f 1 )"
    head_2="$(echo $head_range | cut -d ' ' -f 2 )"
    
    # 从hugo头取得标题
    POST_TITLE="$(sed -n ${head_1},${head_2}p /dev/shm/arti.esc.md | grep -E "^[[:space:]]*title[[:space:]]*:[[:space:]]*" | cut -d ':' -f 2 | sed 's/^[[:space:]]*\"//g' | sed 's/\"[[:space:]]*$//g' )"
    
    # 去掉hugo头
    sed -i ${head_1},${head_2}d /dev/shm/arti.esc.md

    # 去掉hugo变量
    sed -i 's/^[[:space:]]*{{<.*>}}//g' /dev/shm/arti.esc.md 
    # 转换 & < > 换行
    sed -i 's/&/\&amp;/g' /dev/shm/arti.esc.md
    sed -i 's/</\&lt;/g' /dev/shm/arti.esc.md
    sed -i 's/>/\&gt;/g' /dev/shm/arti.esc.md
    sed -i 's/$/\&#x000A;/g' /dev/shm/arti.esc.md

    
    ARTI="$(cat '/dev/shm/arti.esc.md')"

    cat > /dev/shm/edit_post.xml << EOF
<?xml version="1.0"?>
    <methodCall>
    <methodName>metaWeblog.editPost</methodName>
    <params>
        <param>
            <value><string>$POST_ID</string></value>
        </param>
        <param>
            <value><string>$ACCOUNT</string></value>
        </param>
        <param>
            <value><string>$PASSWD</string></value>
        </param>
        <param>
            <value>
                    <struct>
                        <member>
                            <name>description</name>
                            <value>
                                <string>$ARTI</string>
                            </value>
                        </member>
                        <member>
                            <name>title</name>
                            <value>
                                <string>$POST_TITLE</string>
                            </value>
                        </member>
                        <member>
                            <name>categories</name>
                            <value>
                                <array>
                                    <data>
                                        <value>
                                            <string>[Markdown]</string>
                                        </value>
                                    </data>
                                </array>
                            </value>
                        </member>
                    </struct>
                </value>
        </param>
        <param>
            <value><boolean>1</boolean></value>
        </param>
    </params>
    </methodCall> 
EOF

    curl  https://rpc.cnblogs.com/metaweblog/$CNBLOG_BLOG  -H "Content-Type: text/xml" --data @/dev/shm/edit_post.xml 
    rm /dev/shm/edit_post.xml 
done
