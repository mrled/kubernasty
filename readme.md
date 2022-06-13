# Kubernasty

An Alpine-based k3s cluster automation system.

Status: Very incomplete, it boots tho

Goals:

- OS is small and fully in RAM
- OS image is the same for each node
- Nodes have a small USB drive containing its nodename and a secret key (see [System secrets and individuation](./docs/system-secrets-individuation.md))
- Once booted, the nodes use the nodename and secret key to call out to the network and configure themselves in RAM
- Once configuration is finished, k3s cluster starts

## To do

- Configure more complex stuff after boot.
    - Tailscale
    - The data storage for the system at /data or whatever
    - k3s
- How to configure post boot?
    - Should this be Ansible?
    - Maybe it should be simple shell scripts? Ansible is so slow...
    - What kind of server will it need?
    - I'd like this to be a simple object store, so I could put it anywhere on HTTP/S3 and be able to move it wherever I want
    - Maybe something like a `knty-cnc.micahrl.com/postboot.json` page that contains a dict of nodename:instructions paired, built by hand maybe, or with a SSG.
    - Encrypt the instructions per host so that the host can be sure that instructions it gets over the network are trustworthy
    - Instructions could be location of a script to download and run, or a tarball to download/extract/run some specific script from. In either case, it would also be encrypted.
- Make an update mechanism
    - Service that checks for OS updates once/day or something, maybe via similar method like `knty-cnc.micahrl.com/os-update.json`
    - If there's an update, download it to a temp dir, and overwrite the USB drive that contains the OS with it. I hope u tested it!
    - In a real environment, you'd want an atomic update, but I'm not going to make that here.
    - In a real environment, you'd want the ability to roll back too.
- Misc
    - It regenerates SSH host keys on each boot, which takes a minute; can we avoid this somehow? (Or only generate one pair?)
