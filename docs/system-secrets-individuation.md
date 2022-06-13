# System secrets and individuation

Each system has to have a private key so that we can encypt things for it,
like kubernetes cluster initialization tokens and other secrets.

We assume a dedicated USB drive always installed with a label of `knty-secret`,
which is mounted during the execution of the `kubernasty-postboot` local script.
It should contain the following:

- `nodename`, a file containing the node's name. This might not be a proper hostname, but it should be unique.
- `age.key`, a file containing an [age](https://age-encryption.org) private key.
- Optionally `TESTONLYNOPROD.env`, which contains some variables that are useful in development but dangerous in production.

This information will be used to call out to the network and configure the system.

The nodename and the age PUBLIC key (visible in the private key file) should be saved elsewhere so that configs and (especially) secrets can be encrypted separately per node. The private key should reside only on the USB drive.

Make one like this:

```sh
# The name you want to use for this node
nodename=millenium-falcon

# The name of the USB devie, e.g. 'device=/dev/sdb'
# No need for partitions
device=/dev/xxx

# Make a filesystem
mkfs.ext4 $device

# Add a label that shows up in blkid and can be used in fstab
e2label $device 'knty-secret'

# Mount it
mkdir -p /mnt/knty-secret-new
mount $device /mnt/knty-secret-new

# Save the nodename
echo "$nodename" > /mnt/knty-secret-new

# Create an age private key
# The public key will be displayed to stdout
age-keygen -o /mnt/knty-secret-new/key.age
```

## Future research

- Can I do this in the TPM without a dedicated USB drive?
