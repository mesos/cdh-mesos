# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# included in all the hadoop scripts with source command
# should not be executable directly
# also should not be passed any arguments, since we need original $*

# resolve links - $0 may be a softlink

this="$0"
while [ -h "$this" ]; do
  ls=`ls -ld "$this"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '.*/.*' > /dev/null; then
    this="$link"
  else
    this=`dirname "$this"`/"$link"
  fi
done

# convert relative path to absolute path
bin=`dirname "$this"`
script=`basename "$this"`
bin=`cd "$bin"; pwd`
this="$bin/$script"

# the root of the Hadoop installation
if [ -z "$HADOOP_HOME" ]; then
  export HADOOP_HOME=`dirname "$this"`/..
fi

# double check that our HADOOP_HOME looks reasonable.
# cding to / here verifies that we have an absolute path, which is
# necessary for the daemons to function properly
if [ -z "$(cd / && ls $HADOOP_HOME/hadoop-core-*.jar $HADOOP_HOME/build 2>/dev/null)" ]; then
  cat 1>&2 <<EOF
+================================================================+
|      Error: HADOOP_HOME is not set correctly                   |
+----------------------------------------------------------------+
| Please set your HADOOP_HOME variable to the absolute path of   |
| the directory that contains hadoop-core-VERSION.jar            |
+================================================================+
EOF
  exit 1
fi

#check to see if the conf dir is given as an optional argument
if [ $# -gt 1 ]
then
    if [ "--config" = "$1" ]
	  then
	      shift
	      confdir=$1
	      shift
	      HADOOP_CONF_DIR=$confdir
    fi
fi
 
# Allow alternate conf dir location.
HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/conf}"

if [ -f "${HADOOP_CONF_DIR}/hadoop-env.sh" ]; then
  . "${HADOOP_CONF_DIR}/hadoop-env.sh"
fi

# attempt to find java
if [ -z "$JAVA_HOME" ]; then
  for candidate in \
    /usr/lib/jvm/java-6-sun \
    /usr/lib/j2sdk1.6-sun \
    /usr/java/jdk1.6* \
    /usr/java/jre1.6* \
    /Library/Java/Home \
    /usr/java/default \
    /usr/lib/jvm/default-java ; do
    if [ -e $candidate/bin/java ]; then
      export JAVA_HOME=$candidate
      break
    fi
  done
  # if we didn't set it
  if [ -z "$JAVA_HOME" ]; then
    cat 1>&2 <<EOF
+======================================================================+
|      Error: JAVA_HOME is not set and Java could not be found         |
+----------------------------------------------------------------------+
| Please download the latest Sun JDK from the Sun Java web site        |
|       > http://java.sun.com/javase/downloads/ <                      |
|                                                                      |
| Hadoop requires Java 1.6 or later.                                   |
| NOTE: This script will find Sun Java whether you install using the   |
|       binary or the RPM based installer.                             |
+======================================================================+
EOF
    exit 1
  fi
fi

if [ -d $HADOOP_HOME/pids ]; then
HADOOP_PID_DIR="${HADOOP_PID_DIR:-$HADOOP_HOME/pids}"
fi

#check to see it is specified whether to use the slaves or the
# masters file
if [ $# -gt 1 ]
then
    if [ "--hosts" = "$1" ]
    then
        shift
        slavesfile=$1
        shift
        export HADOOP_SLAVES="${HADOOP_CONF_DIR}/$slavesfile"
    fi
fi
