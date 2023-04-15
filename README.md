# kube-monitor

Bash scripts for Kubernetes Monitoring

### kube-ns-stat.sh

This will print the number of services, pods, unhealthy pods, restarting pods, and pending pods, with colour coding
usage:
Specific Namespace(s) can be given as arguments. if you want all namespaces to be printed then simply pass 'all' as the argument.


E.g.
``` bash
sh kube-ns-stat.sh kube-node-lease kube-system
```

``` bash
sh kube-ns-stat.sh all
```


### refresh.sh

This is a generic script to run another script in the background and refresh the display at specific intervals
usage:

arg#1 is frequency in number of seconds
arg#2 is the actual script name
arg#3..n can be the arguments to the actual script


E.g.
``` bash

sh refresh.sh 1 kube-ns-stat.sh kube-node-lease

```



