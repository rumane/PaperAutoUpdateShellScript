#!/bin/bash

URL="https://papermc.io/api/v1/paper/1.17.1/latest"

runServer() {
    echo -e "\n서버 설정: "

    echo -e "\nXMS: (<Number><M/G>)"
    read XMS

    echo -e "\nXMX: (<Number><M/G>)"
    read XMX

    echo -e "\nNoGUI: (true/false)"
    read NOGUI

    echo -e "\n서버를 실행합니다.\n"
    if [ ${NOGUI} == "true" ] ; then
        java -Xms${XMS} -Xmx${XMX} -jar paper.jar nogui

    elif [ ${NOGUI} == "false" ] ; then
        java -Xms${XMS} -Xmx${XMX} -jar paper.jar

    else
        java -Xms${XMS} -Xmx${XMX} -jar paper.jar
    fi
    exit 0
}

download() {
    wget "${URL}/download" -O paper.jar
}

createFile() {
    name=$1
    echo -e ${name} > latestVersion.txt
}


# 만약 파일이 존재하지 않을때 생성
if [ ! -e "latestVersion.txt" ] ; then
    createFile "0"
    echo -e "\n파일을 생성했습니다."
fi

# 현재 버전 구하기
for LIST in `cat latestVersion.txt`; do
    CURRENT_VERSION=${LIST}
done

# 최신 버전 구하기
JSON=`curl ${URL}`
BUILD_INFO=`echo ${JSON} | cut -d',' -f3`
VAR=`echo ${BUILD_INFO} | cut -d':' -f2`
LATEST_VERSION=`echo ${VAR} | cut -d'}' -f1`

#크기 비교
if [ "${CURRENT_VERSION}" -lt "${LATEST_VERSION}" ] ; then # CURRENT_VERSION < LATEST_VERSION
    echo -e "\n새로운 버전의 버킷이 나왔습니다."
    echo -e "\n업데이트 하시겠습니까? (y/n)"
    read ANSWER

    if [ ${ANSWER} == y ] ; then # YES
        echo -e "\n업데이트 시작"
        download
        createFile ${LATEST_VERSION}
        echo -e "\n업데이트를 완료하였습니다."

    elif [ ${ANSWER} == n ] ; then # NO
        echo -e "\n업데이트를 취소하였습니다."
    fi
else
    echo -e "\n현재 버킷은 최신 버전 입니다."
fi

runServer