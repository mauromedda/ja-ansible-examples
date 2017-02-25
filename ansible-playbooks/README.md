# Play order execution

Ansible is designed to be simple to understand and usage.

A playbook has only two main operations. It can either run playbook or it can
includes other playbooks from files in the filesystem.

The order in which these operations are accomplished is the order in which they
appear in the playbook from top to bottom. It is important to understand that
the operations are executed in order, the entire playbook and any included
files are parsed and loaded before any execution. That means that any playbook
file must exists at time of playbook parsing.

Below I show the order in which the permitted playbook operations will happen:

    - variable loading
    - fact gathering
    - pre_tasks
    - handler of pre_tasks
    - tasks and roles
    - handlers of tasks and roles
    - post_tasks
    - handlers of post_tasks

Indeptendent from the order in which these blocks appears in the playbook, they
will be process in the order above.
The order.yml playbook contains all the operations above.

## Execution

```bash

$ ansible-playbook order.yml

```


## Author

Mauro Medda aka deftunix < medda.mauro at gmail dot com >
