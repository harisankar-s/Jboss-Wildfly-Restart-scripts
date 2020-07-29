#!/bin/bash

rm -f nohup.out
nohup ./standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 --server-config=standalone.xml -Dcommonutil.xml.pretty.format=true -Duser.timezone=UTC+05:30 &
