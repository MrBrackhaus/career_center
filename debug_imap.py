import imaplib
import email
from email.header import decode_header
import sys

# Windows console encoding
sys.stdout.reconfigure(encoding='utf-8')

def decode_mime_words(s):
    if not s: return ''
    return u''.join(
        word.decode(charset or 'utf-8', errors='ignore') if isinstance(word, bytes) else word
        for word, charset in decode_header(s)
    )

try:
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login('bewerbung.kurz@gmail.com', 'tmvq wedg nevq nioy')

    status, mailboxes = mail.list()
    
    # Try selecting Sent mailbox
    sent_box = '"[Gmail]/Gesendet"'
    status, res = mail.select(sent_box)
    
    if status != 'OK':
        print(f"Could not open {sent_box}. Mailboxes:")
        for box in mailboxes:
            print(box.decode())
        sys.exit(1)

    status, response = mail.search(None, 'ALL')
    msg_ids = response[0].split()

    print(f"Total sent messages: {len(msg_ids)}")
    
    # Get last 15 messages
    for num in msg_ids[-15:]:
        typ, data = mail.fetch(num, '(RFC822)')
        raw_email = data[0][1]
        msg = email.message_from_bytes(raw_email)
        
        subject = decode_mime_words(msg['Subject'])
        to = decode_mime_words(msg['To'])
        
        print(f'\n--- EMAIL {num.decode()} ---')
        print(f'Subject: {subject}')
        print(f'To: {to}')
        
        body = ''
        if msg.is_multipart():
            for part in msg.walk():
                if part.get_content_type() == 'text/plain':
                    body = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                    break
        else:
            if msg.get_content_type() == 'text/plain':
                body = msg.get_payload(decode=True).decode('utf-8', errors='ignore')
            
        print(f'Body: {body[:150].replace(chr(10), " ")}')

    mail.close()
    mail.logout()

except Exception as e:
    print(f"Error: {e}")
