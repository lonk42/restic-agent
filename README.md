# Restic Agent
This is a collection of BASH scripts to run and manage linux backups with restic to backblaze.

The scripts are designed to be added to multiple hosts backing up to the same bucket. The restic repos are also added with an optional 'master' key in mind, the master key should be applied to all repos allowing restoration if you lose the local key for them. This master key is also used allow checks from a single host against all its clients.


## Config
defaults.config provides examples or available options, to customize these make a copy of this file.
```
cp defaults.config config
```

### Backblaze credentials
Your config needs your backblaze keys, the export is required.
```
export B2_ACCOUNT_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export B2_ACCOUNT_ID="YYYYYYYYYYYYYYYYYYYYYYY"
```

### Restic password file
The key to encrypt your restic backups needs to be in the file 'restic-password.secret', there is no format the entire string is read as the key. The location of this file can be adjusted with the config variable 'RESTIC_PASSWORD_FILE'.

### Restic master key
The master key is optional if using the 'master' scripts, the format as the restic key.

## Running via cron
An example cronjob is supplied, if this suits it can simply be symlinked. Otherwise supply it to cron via your preffered method and frequency.
```
ln -s /home/git/restic-agent/restic-agent-cron /etc/cron.d/
```

## Restic CLI
A wrapper script 'restic-cli.sh' allows you to run restic commands as if you were using the restic CLI.
```
./restic-cli.sh --help
```
