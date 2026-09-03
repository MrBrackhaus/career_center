# -*- coding: utf-8 -*-
import os

files_to_fix = [
    'lib/core/router/app_router.dart',
    'lib/presentation/screens/settings/settings_screen.dart',
    'lib/presentation/screens/applications/applications_screen.dart',
    'lib/l10n/app_de.arb',
    'lib/l10n/app_en.arb'
]

replacements = {
    b'\xc3\x83\xc2\xbc': b'\xc3\xbc', 
    b'\xc3\x83\xc2\xa4': b'\xc3\xa4', 
    b'\xc3\x83\xc2\xb6': b'\xc3\xb6', 
    b'\xc3\x83\x9c': b'\xc3\x9c',     
    b'\xc3\x83\x84': b'\xc3\x84',     
    b'\xc3\x83\x96': b'\xc3\x96',     
    b'\xc3\x83\x9f': b'\xc3\x9f',     
    b'\xc3\x83\xc6\x92\xc3\x85\xe2\x80\x9c': b'\xc3\x9c', 
    b'\xc3\x83\xc6\x92\xc3\x82\xc2\xbc': b'\xc3\xbc', 
    b'f\xc3\x83\xc2\xbcr': b'f\xc3\xbcr',
    b'Pers\xc3\x83\xc2\xb6nliche': b'Pers\xc3\xb6nliche',
    b'Eigenbem\xc3\x83\xc2\xbchungen': b'Eigenbem\xc3\xbchungen',
    b'ausw\xc3\x83\xc2\xa4hlen': b'ausw\xc3\xa4hlen',
    b'L\xc3\x83\xc2\xb6schen': b'L\xc3\xb6schen',
    b'M\xc3\x83\xc2\xb6chtest': b'M\xc3\xb6chtest',
    b'B\xc3\x83\xc2\xbcro': b'B\xc3\xbcro',
    b'Zus\xc3\x83\xc2\xa4tzliche': b'Zus\xc3\xa4tzliche',
    b'R\xc3\x83\xc2\xbcckmeldungen': b'R\xc3\xbcckmeldungen',
    b'\xc3\x83\x84nderungen': b'\xc3\x84nderungen',
    b'schlie\xc3\x83\xc2\x9fe': b'schlie\xc3\x9fe',
    b'hinzugef\xc3\x83\xc2\xbcgt': b'hinzugef\xc3\xbcgt',
    b'Gespr\xc3\x83\xc2\xa4ch': b'Gespr\xc3\xa4ch',
    b'w\xc3\x83\xc2\xa4hlen': b'w\xc3\xa4hlen',
    b'gel\xc3\x83\xc2\xb6scht': b'gel\xc3\xb6scht',
    b'h\xc3\x83\xc2\xa4ttest': b'h\xc3\xa4ttest',
    b'Empf\xc3\x83\xc2\xa4ngt': b'Empf\xc3\xa4ngt',
    b'Eintr\xc3\x83\xc2\xa4ge': b'Eintr\xc3\xa4ge',
    b'F\xc3\x83\xc2\xbchrerscheine': b'F\xc3\xbchrerscheine',
    b'pr\xc3\x83\xc2\xbcfen': b'pr\xc3\xbcfen',
    b'F\xc3\x83\xc2\xbcr': b'F\xc3\xbcr',
}

for f_path in files_to_fix:
    if not os.path.exists(f_path): continue
    with open(f_path, 'rb') as f:
        data = f.read()
    
    for bad, good in replacements.items():
        data = data.replace(bad, good)
        
    data = data.replace(b'Profi-\xef\xbf\xbdobersicht', b'Profi-\xc3\x9cbersicht')
    data = data.replace(b'Profi-\xc3\x83\x85\xe2\x80\x9cobersicht', b'Profi-\xc3\x9cbersicht')
    data = data.replace(b'Profi-\xc3\x83\xc6\x92\xc3\x85\xe2\x80\x9cbersicht', b'Profi-\xc3\x9cbersicht')
    data = data.replace(b'Profi-\xc3\x83\x85\xc2\x93bersicht', b'Profi-\xc3\x9cbersicht')
    data = data.replace(b'Zeit f\xef\xbf\xbdr', b'Zeit f\xc3\xbcr')
    data = data.replace(b'Zeit f\xc3\x83\xc2\xbcr', b'Zeit f\xc3\xbcr')
    data = data.replace(b'Zeit f\xc3\x83\xc6\x92\xc3\x82\xc2\xbcr', b'Zeit f\xc3\xbcr')
    
    with open(f_path, 'wb') as f:
        f.write(data)
    print("Fixed " + f_path)
