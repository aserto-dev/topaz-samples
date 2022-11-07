#!/usr/bin/env bash

TOPAZ_SVC=localhost:9292

cat assertions.json | jq -c '.assertions[] ' | (
    while read BODY; do
        REQ=$(echo $BODY | jq '.check_relation')
        EXP=$(echo $BODY | jq '.expected')
        RSP=$(grpcurl -insecure -d "${REQ}" ${TOPAZ_SVC} aserto.directory.reader.v2.Reader.CheckRelation | jq '.check // false')
        
        if [ "$EXP" = "$RSP" ]; then
            echo "PASS"
        else
            echo "FAIL REQ:$(echo ${REQ} | jq -c .)"
        fi
    done
)
