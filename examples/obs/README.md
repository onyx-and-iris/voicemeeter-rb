## Requirements

- [OBS Studio v28+](https://obsproject.com/)
- [OBSWS Ruby wrapper for Websocket v5](https://github.com/onyx-and-iris/obsws-ruby)

## About

A simple demonstration showing how to sync OBS scene switches to Voicemeeter states.

## Use

The script assumes you have connection info saved in a config yaml file named `config.yaml` placed next to `obs.rb`. It also assumes you have scenes named `START` `BRB` `END` and `LIVE`.

A valid `config.yaml` file might look like this:

```yaml
connection:
  host: localhost
  port: 4455
  password: strongpassword
```

Closing OBS will end the script and logout of Voicemeeter.
