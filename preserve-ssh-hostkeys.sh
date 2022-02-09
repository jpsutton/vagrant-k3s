cd /vagrant

keydir=".hostkey-cache/"$(hostname)
mkdir -p "$keydir" && cd "$keydir"

if [ `ls | wc -l` -eq 0 ]; then
  sudo cp /etc/ssh/ssh*key* .
else
  sudo cp * /etc/ssh
  cd /etc/ssh
  sudo chown root:root ssh*key*
  sudo chmod 600 ssh*key*
  sudo chmod 644 ssh*key*.pub
  sudo systemctl restart sshd
fi
