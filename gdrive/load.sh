#!/usr/bin/env bash

TOPAZ_SVC=localhost:9292
SESSION_ID="1e2ad684-3b8d-4836-8abe-f09c3c581f78"

cat model.json | jq -c '.object_types[]' | (
    while read DATA; do
        grpcurl \
        -H "aserto-session-id: ${SESSION_ID}" \
        -insecure \
        -d "${DATA}" \
        ${TOPAZ_SVC} \
        aserto.directory.writer.v2.Writer.SetObjectType | jq '.'
    done
)

cat model.json | jq -c '.permissions[]' | (
    while read DATA; do
        grpcurl \
        -H "aserto-session-id: ${SESSION_ID}" \
        -insecure \
        -d "${DATA}" \
        ${TOPAZ_SVC} \
        aserto.directory.writer.v2.Writer.SetPermission | jq '.'
    done
)

cat model.json | jq -c '.relation_types[]' | (
    while read DATA; do
        grpcurl \
        -H "aserto-session-id: ${SESSION_ID}" \
        -insecure \
        -d "${DATA}" \
        ${TOPAZ_SVC} \
        aserto.directory.writer.v2.Writer.SetRelationType | jq '.'
    done
)

cat tuples.json | jq -c '.objects[]' | (
    while read DATA; do
        grpcurl \
        -H "aserto-session-id: ${SESSION_ID}" \
        -insecure \
        -d "${DATA}" \
        ${TOPAZ_SVC} \
        aserto.directory.writer.v2.Writer.SetObject | jq '.'
    done
)

cat tuples.json | jq -c '.relations[]' | (
    while read DATA; do
        grpcurl \
        -H "aserto-session-id: ${SESSION_ID}" \
        -insecure \
        -d "${DATA}" \
        ${TOPAZ_SVC} \
        aserto.directory.writer.v2.Writer.SetRelation | jq '.'
    done
)
