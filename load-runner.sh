#!/bin/bash

echo "Generate some load to the publish service."

echo "All arguments:"
echo $@
echo "================="

HOST=$1
OUTPUT=""

echo "Host    : ${HOST}"
echo "================="

#while curl -sI -o -v /dev/null -w "%{http_code}\n" "http://${HOST}/bomc/api/metadata/annotation-validation" -H  "accept: application/json" -H  "X-B3-TraceId: 82f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 11e3ac9a4f6e3b90" -H  "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"bomc\"}"; do sleep 3; done;

while 
    curl -I -o OUTPUT -w "%{http_code}" "http://${HOST}/bomc/api/metadata/annotation-validation" -H  "accept: application/json" -H  "X-B3-TraceId: 82f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 11e3ac9a4f6e3b90" -H  "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"bomc\"}"; 
    echo ${OUTPUT}
    do sleep 3; 
done;