# printerclub

What if pen pals, but a little more modern? Printerclub is a simple bash script designed for Raspberry Pi that makes it easy for your friends to send messages that are printed directly on your printer. Sort of like a fax machine, but no phone line needed. 

# Requirements

* A Raspberry Pi (or similar linux server) that is always running
* A printer, either connected to the Raspberry Pi on the same local network
* A Gmail or other email account used to receive messages
* One or more friends to send you messages

# How it Works

Printerclub is a bash script that checks your email account for new messages that meet certain conditions (by default emails with the word "printme" in the subject line). Set up to run periodically, it will download new messages, extract the attachments, then the attachments to your printer. That's it! 

# Setup

First, clone the repo to your location of choice. For purposes of this README, I'll assume you clone it to `~/code/printerclub`.

```bash
cd ~/code
git clone https://github.com/yesezra/printerclub
```

Before configuring the Printerclub script, you'll need to install three prerequsites on your Raspberry Pi.

```bash
sudo apt install cups #install the [CUPS printer system](https://www.cups.org)
sudo apt install getmail #install the [getmail mail retriever](https://pyropus.ca./software/getmail/)
sudo apt install maildir-utils #install [mu](https://www.djcbsoftware.nl/code/mu/)
```

Next, ensure that your printer is configured on your Raspberry Pi. [Here's a thorough guide](https://raspberrytips.com/install-printer-raspberry-pi/). If you don't have a GUI on your Pi, I highly recommend following the steps to enable the CUPS web interface at localhost:631 and configuring your printer from there. Note that if you are trying to use this interface from outside your Pi, you'll need to replace `Listen localhost:631` with `Port 631` in `/etc/cups/cupsd.conf`, as well as adding an `Allow @local` directive in each `<Location>` section. Again, follow the steps at the link.

If you have more than one printer installed, set a default printer. First, use this command to get a list of all installed printers:
```bash
lpstat -p -d
```
Then, set the default printer
```bash
lpoptions -d [printer]
``````

Once configured, test your configuration by printing an image or pdf from the command line:

```bash
lp [insert any sample image or pdf here]
```
Now, we'll configure getmail. First, create getmail's required config directory:

```bash
mkdir ~/.getmail
chmod 700 ~/.getmail
```
Then, copy the the example `getmailrc` to the directory you just created:

```bash
cp ~/code/printerclub/getmailrc.example ~/.getmail/getmailrc__
```

At this point, you'll need to edit your getmailrc to your email account's server address, username, and password for your email account. The example uses the IMAP interface to Gmail. If you don't already have IMAP enabled, you'll need to do so in your Gmail settings > Forwarding and POP/IMAP > Enable IMAP. 

Note: For security purposes, you should create an App Password for your Google account and use it instead of your account's full password. Follow [these steps](https://support.google.com/mail/answer/185833?hl=en) to set one up.

By default, getmail is configured to download messages with the "printme" label in Gmail. This is a good time to create that label in your Gmail account. I recommend creating a filter that automatically adds the printme label to emails with subjects that include "printme". I also recommend that these emails skip the inbox, so you get a nice surprise in your printer.

<img width="400" alt="Gmail search showing a match for subject includes printme" src="https://github.com/yesezra/printerclub/assets/173440/5d03bd53-e566-415c-8c00-7073b3ae37e7">
<img width="400" alt="Gmail filter config showing skip inbox and autoapply label" src="https://github.com/yesezra/printerclub/assets/173440/0bc93c9f-ffd4-4447-a946-7c830d2aa311">


Getmail offers many options so if the defaults don't work, review [the docs](https://pyropus.ca./software/getmail/) and edit your config as needed. The only critical option is to store messages in the Maildir format (`type = Maildir`) and in the proper location (`path = ~/.printerclub/Maildir/`).

To confirm that getmail is configured properly, run it from the command line. Ensure a message has the `printme` label so there's a message to pull down!

```bash
getmail
```

If you see no errors, you should be ready to test the script! Run printerclub.sh:

```bash
chmod u+x ~/code/printerclub/printerclub.sh #make the script executable!
~/code/printerclub/printerclub.sh
```

At this point, you can configure cron to run the script automatically:
```bash
crontab -u pi -e #replace "pi" with your Raspberry Pi user account
```
You may need to select an editor if you don't have one set. You'll want to add the following line to the bottom of the file, then save and exit the editor. 
```cron
*/15 * * * * /home/pi/code/printerclub/printerclub.sh
```
This will run the script every 15 minutes, but you can use normal cron syntax to change this if you like. 

Finally, the script is installed and configured – the last step is to tell your friends to send you messages!

# Uninstalling

```bash
rm -rf ~/.printerclub
rm -rf ~/.getmail
crontab -e -u pi
```
