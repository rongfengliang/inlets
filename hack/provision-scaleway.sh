#!/bin/bash

export SUFFIX=$(head -c 16 /dev/urandom | shasum | cut -c1-8)
export NAME="inlets$SUFFIX"
echo "Creating: $NAME"

rm ~/.scw-cache.db
export FILE=`pwd`/hack/userdata.sh

scw --region=par1 run --detach -u="FILE=$FILE" --commercial-type=START1-XS --name=$NAME ubuntu-mini-xenial-25g

for i in {0..100};
do
  sleep 5
  status=$(scw --region=par1 inspect -f {{.State}} server:"$NAME")
  if [ ! $? -eq 0 ];
  then
    echo "Unable to inspect server"
    rm ~/.scw-cache.db
    continue
  fi
  echo "Status: $status"

  if [ $status == "running" ];
  then
    echo IP: $(scw inspect -f {{.PublicAddress.IP}} $NAME)
    break
  fi
done



