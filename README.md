# LVM copy via SSH
This bash script copies a logical volume (LVM) from the local machine (*source*) to a remote server (*destination*) via SSH, creating before a LVM in the remote machine with the same size as the source volume.

## Usage
The arguments for the script are:
* **group**: Volume group
* **volume**: Logical volume name
* **dest**: IP address or hostname of the **target** server and, optionally, SSH user preceded by "@"
* verify (optional): verify the integrity of the transferred data

## Examples

* Transfer the logical volume under `/dev/vg0/myvol` to the remote server with IP address 192.168.1.2:

`./lvm-ssh-transfer.sh --group vg0 --volume myvol --dest root@192.168.1.2`

* Transfer a logical volume and also checking the integrity of the transferred data:

`./lvm-ssh-transfer.sh --group vg0 --volume myvol --dest root@192.168.1.2 --verify`

## Download &amp; installation
Just download the file `lvm-ssh-transfer.sh` to the source server and execute it. Make sure the .sh file has execution rights.

```bash
wget https://raw.githubusercontent.com/daniol/lvm-ssh-transfer/master/lvm-ssh-transfer.sh
chmod +x lvm-ssh-transfer.sh
```

## Requirements

The following packages are required:

* openssh-client (source server)
* openssh-server (destination server)
* lvm2 (both servers)

## F.A.Q.

### This script asks me for the SSH password two times
If you don't want to enter the SSH password each time, you should copy the ssh public key using `ssh-copy-id`. Look [here](https://www.ssh.com/ssh/copy-id/]) for more information.

### It takes a long to complete
The transfer time can take a long time, depending on the size of the volume and the speed of the network. This script does not print any progress and quits when the transfer completes. My tests with a good internet connection in both servers show an average speed around 90 MB/s.

> 107374182400 bytes (107 GB, 100 GiB) copied, 1194.33 s, 89.9 MB/s

### Where should I execute this script, on the source or target server?
This script must be executed from the source server, as specified.

### How to verify if the data was copied successfully?
The script will output error messages and forwards the error code of the commands as exit code.
If you want to get 100% sure if the data was successfully transferred, you can supply the option `--verify` to execute sha1sum on the source and target server and verify the integrity of the transferred data.

### I found a bug or I suggest an improvement

Just create a new [issue](https://github.com/daniol/lvm-ssh-transfer/issues/new) or make a [pull request](https://github.com/daniol/lvm-ssh-transfer/pulls) if you are developer. You are welcome!

### Why this script and not just "dd | ssh"?

If you only execute `dd` and transfer the data via ssh, it is not going to work well as expected, because:
* It will not create the logical volume in the target server
* It would create a file under `/dev/mygroup/myvol` in the root disk
* It will not create a local volume using the disk free space
* The copied volume file would not appear on management tools like `lvdisplay`.
