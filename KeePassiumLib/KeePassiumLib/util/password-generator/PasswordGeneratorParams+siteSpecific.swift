//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  Auto-generated from password-manager-resources
//  Source: https://github.com/keepassium/password-manager-resources
//
//  DO NOT EDIT MANUALLY
//  Run: ./scripts/generate-password-rules.swift

import Foundation

extension PasswordGeneratorParams {
    public static let siteSpecific: [String: CustomPasswordGeneratorParams] = [
        "163.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "1800flowers.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "access.service.gov.uk": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "account.samsung.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "acmemarkets.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "act.org": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "admiral.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .required: "- !\"#$&'()*+,.:;<=>?@[^_`{|}~]",
            ]
        ),
        "ae.com": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "aeon.co.jp": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$+./:=?@[^_|~]",
            ],
            maxConsecutive: 3
        ),
        "aeromexico.com": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "aetna.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-_&#@",
            ],
            maxConsecutive: 2
        ),
        "airasia.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "airfrance.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!#$&+/?@_",
            ]
        ),
        "airfrance.us": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!#$&+/?@_",
            ]
        ),
        "ajisushionline.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: " !#$%&*?@",
            ]
        ),
        "albertsons.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "alelo.com.br": CustomPasswordGeneratorParams(
            length: 10,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "aliexpress.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "alliantcreditunion.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$*",
            ],
            maxConsecutive: 3
        ),
        "allianz.com.br": CustomPasswordGeneratorParams(
            length: 4,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "americanexpress.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "%&_?#=",
            ],
            maxConsecutive: 4
        ),
        "amnh.org": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "ana.co.jp": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "anatel.gov.br": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "ancestry.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "andronicos.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "angieslist.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "anthem.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!$*?@|",
            ],
            maxConsecutive: 3
        ),
        "app.digiboxx.com": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@$!%*?&",
            ]
        ),
        "app.digio.in": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "app.parkmobile.io": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&",
            ]
        ),
        "app8menu.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@$!%*?&",
            ]
        ),
        "apple.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "appleloan.citizensbank.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%@^_",
            ],
            maxConsecutive: 2
        ),
        "areariservata.bancaetica.it": CustomPasswordGeneratorParams(
            length: 10,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#&*+/=@_",
            ]
        ),
        "artscyclery.com": CustomPasswordGeneratorParams(
            length: 19,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "astonmartinf1.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "auth.readymag.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "auth.zennioptical.com": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "autify.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!\"#$%&'()*+,./:;<=>?@[^_`{|}~]",
            ]
        ),
        "axa.de": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!\"§$%&/()=?;:_+*'#",
            ]
        ),
        "baidu.com": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "balduccis.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "bancochile.cl": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "bankofamerica.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-@#*()+={}/?~;,._",
            ],
            maxConsecutive: 3
        ),
        "battle.net": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "bcassessment.ca": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "belkin.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "$!@~_,%&",
            ]
        ),
        "benefitslogin.discoverybenefits.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@",
            ]
        ),
        "benjerry.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "bestbuy.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "bhphotovideo.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "bilibili.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "billerweb.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            maxConsecutive: 2
        ),
        "biovea.com": CustomPasswordGeneratorParams(
            length: 19,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "bitly.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "`!@#$%^&*()+~{}'\";:<>?]",
            ]
        ),
        "blackwells.co.uk": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "bloomingdales.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "`!@#$%^&*()+~{}'\";:<>?]",
            ]
        ),
        "bluesguitarunleashed.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "!$#@",
            ]
        ),
        "bochk.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "#$%&()*+,.:;<=>?@_",
            ],
            maxConsecutive: 3
        ),
        "box.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "bpl.bibliocommons.com": CustomPasswordGeneratorParams(
            length: 4,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "brighthorizons.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "callofduty.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            maxConsecutive: 2
        ),
        "candyrect.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "capitalone.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-_./\\@$*&!#",
            ]
        ),
        "cardbenefitservices.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "cardcash.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!$%&*?@",
            ]
        ),
        "carrefour.it": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@_",
            ]
        ),
        "carrsqc.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "carte-mobilite-inclusion.fr": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "cathaypacific.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$*^",
            ]
        ),
        "cb2.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#*_%.$",
            ]
        ),
        "ccs-grp.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!#$%&'+./=?\\^_`{|}~",
            ]
        ),
        "cecredentialtrust.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "charlie.mbta.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%@^",
            ]
        ),
        "chase.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%+/=@~",
            ],
            maxConsecutive: 2
        ),
        "cigna.co.uk": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "citi.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-~`!@#$%^&*()_\\/|",
            ],
            maxConsecutive: 2
        ),
        "claimlookup.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@#$%^&+=!",
            ]
        ),
        "clarksoneyecare.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "~!@#$%^&*()_+{}|;,.<>?[]",
            ]
        ),
        "claro.com.br": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-!@#$%&*_+=<>",
            ]
        ),
        "classmates.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "!@#$%^&*",
            ]
        ),
        "clegc-gckey.gc.ca": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "clien.net": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "cogmembers.org": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "collectivehealth.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "comcastpaymentcenter.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            maxConsecutive: 2
        ),
        "comed.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-~!@#$%^&*_+=`|(){}[:;\"'<>,.?/\\]",
            ]
        ),
        "commerzbank.de": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "consorsbank.de": CustomPasswordGeneratorParams(
            length: 5,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "consorsfinanz.de": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-.",
            ]
        ),
        "costco.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!#$%&'()*+/:;=?@[^_`{|}~]",
            ]
        ),
        "coursera.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "cox.com": CustomPasswordGeneratorParams(
            length: 24,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%()*@^",
            ]
        ),
        "crateandbarrel.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!\"#$%&()*,.:<>?@^_{|}",
            ]
        ),
        "crowdgen.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&()*+=@^_",
            ]
        ),
        "cvs.com": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()",
            ]
        ),
        "dailymail.co.uk": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "dan.org": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@$%^&*",
            ]
        ),
        "danawa.com": CustomPasswordGeneratorParams(
            length: 21,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@$%^&*",
            ]
        ),
        "darty.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "dbs.com.hk": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "decluttr.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "delta.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "deutsche-bank.de": CustomPasswordGeneratorParams(
            length: 5,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "devstore.cn": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "dickssportinggoods.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@^",
            ]
        ),
        "dkb.de": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-äüöÄÜÖß!$%&/()=?+#,.:",
            ]
        ),
        "dmm.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "dodgeridge.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "dowjones.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "ea.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "easycoop.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "easyjet.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-",
            ]
        ),
        "ebrap.org": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%^&*()_+|~=`{}[:\";'?,./.]-!@#$%^&*()_+|~=`{}[:\";'?,./.]",
            ]
        ),
        "ecompanystore.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%*+.=@^_",
            ],
            maxConsecutive: 2
        ),
        "eddservices.edd.ca.gov": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()",
            ]
        ),
        "edistrict.kerala.gov.in": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$",
            ]
        ),
        "empower-retirement.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "epicgames.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!\"#$%&'()*+,./:;<=>?@[^_`{|}~]",
            ]
        ),
        "epicmix.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "equifax.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!$*+@",
            ]
        ),
        "essportal.excelityglobal.com": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "ettoday.net": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "examservice.com.tw": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "expertflyer.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "extraspace.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@",
            ]
        ),
        "ezpassva.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "fc2.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "fccaccessonline.com": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%*^_",
            ],
            maxConsecutive: 3
        ),
        "fedex.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!@#$%^&*_+=`|(){}[:;,.?]",
            ],
            maxConsecutive: 3
        ),
        "fidelity.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!$%+,./:;=?@^_|",
            ],
            maxConsecutive: 2
        ),
        "flysas.com": CustomPasswordGeneratorParams(
            length: 14,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-~!@#$%^&_+=`|(){}[:\"'<>,.?]",
            ]
        ),
        "fnac.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "fuelrewards.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "!#$%@",
            ]
        ),
        "gamestop.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%",
            ]
        ),
        "gap.com": CustomPasswordGeneratorParams(
            length: 24,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%^&*()_+",
            ]
        ),
        "garmin.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "getflywheel.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "girlscouts.org": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "$#!",
            ]
        ),
        "gmx.net": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-<=>~!|()@#{}$%,.?^'&*_+`:;\"[]",
            ]
        ),
        "gocurb.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "$%&#*?!@^",
            ]
        ),
        "google.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-!\"#$%&'()*+,./:;<=>?@[^_{|}~]",
            ]
        ),
        "guardiananytime.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-~!@#$%^&*_+=`|(){}[:;,.?]",
            ],
            maxConsecutive: 2
        ),
        "gwl.greatwestlife.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!#$%_=+<>",
            ]
        ),
        "haggen.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "hangseng.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "hawaiianairlines.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "hertz-japan.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz-kuwait.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz-saudi.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.at": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.be": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.bh": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.ca": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.ch": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.cn": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.co.ao": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.co.id": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.co.kr": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.co.nz": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.co.th": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.co.uk": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.au": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.bh": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.hk": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.kw": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.mt": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.pl": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.pt": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.sg": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.com.tw": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.cv": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.cz": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.de": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.ee": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.es": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.fi": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.fr": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.hu": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.ie": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.it": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.jo": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.lt": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.nl": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.no": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.nu": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.pl": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.pt": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.qa": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.ru": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.se": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertz.si": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hertzcaribbean.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%^&!@",
            ],
            maxConsecutive: 3
        ),
        "hetzner.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-^!$%/()=?+#.,;:~*@{}_&[]",
            ]
        ),
        "hilton.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "hkbea.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "hkexpress.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "hotels.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .required: "-~#@$%&!*_?^",
            ]
        ),
        "hotwire.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-~!@#$%^&*_+=`|(){}[:;\"'<>,.?]",
            ]
        ),
        "hrblock.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "$#%!",
            ]
        ),
        "hsbc.com.hk": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "'.@_",
            ]
        ),
        "hsbc.com.my": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!$*.=?@_'",
            ]
        ),
        "hypovereinsbank.de": CustomPasswordGeneratorParams(
            length: 10,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!\"#$%&()*+:;<=>?@[{}~]",
            ]
        ),
        "hyresbostader.se": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "ichunqiu.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "id.nfpa.org": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-\"^#$%&'()*+:=@[_|{}~]",
            ]
        ),
        "id.sonyentertainmentnetwork.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!@#^&*=+;:",
            ]
        ),
        "id.westfield.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!\"#&'()*,./:;?@[\\^_`{|}~",
            ]
        ),
        "identity.codesignal.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "identitytheft.gov": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "!#%&*@^",
            ]
        ),
        "idestination.info": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "impots.gouv.fr": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-!#$%&*+/=?^_'.{|}",
            ]
        ),
        "indochino.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "inntopia.travel": CustomPasswordGeneratorParams(
            length: 19,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-",
            ]
        ),
        "internationalsos.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@#$%^&+=_",
            ]
        ),
        "irctc.co.in": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()+",
            ]
        ),
        "irs.gov": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@",
            ]
        ),
        "jal.co.jp": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "japanpost.jp": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "jewelosco.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "jordancu-onlinebanking.org": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-!\"#$%&'()*+,.:;<=>?@[^_`{|}~]",
            ]
        ),
        "keldoc.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*",
            ]
        ),
        "kennedy-center.org": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@",
            ]
        ),
        "key.harvard.edu": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-@_#!&$`%*+()./,;~:{}|?>=<^[']",
            ]
        ),
        "kfc.ca": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%&?*",
            ]
        ),
        "kiehls.com": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&?@",
            ]
        ),
        "kingsfoodmarkets.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "klm.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "kundenportal.edeka-smart.de": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!\"§$%&#",
            ]
        ),
        "la-z-boy.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "labcorp.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*",
            ]
        ),
        "ladwp.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "launtel.net.au": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "leetchi.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&()*+,./:;<>?@\"_",
            ]
        ),
        "lepida.it": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!\"#$%&'()*+,.:;<=>?@[^_`{|}~]",
            ],
            maxConsecutive: 2
        ),
        "lg.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!#$%&'()*+,.:;=?@[^_{|}~]",
            ]
        ),
        "linearity.io": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "live.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-@_#!&$`%*+()./,;~:{}|?>=<^'[]",
            ]
        ),
        "lloydsbank.co.uk": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "lowes.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            maxConsecutive: 3
        ),
        "loyalty.accor.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&=@",
            ]
        ),
        "lsacsso.b2clogin.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!#$%&*?@^_",
            ]
        ),
        "lufthansa.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&()*+,./:;<>?@\"_",
            ]
        ),
        "lufthansagroup.careers": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@",
            ]
        ),
        "macys.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "~!@#$%^&*+`(){}[:;\"'<>?]",
            ]
        ),
        "mailbox.org": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!$\"%&/()=*+#.,;:@?{}[]",
            ]
        ),
        "makemytrip.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@$!%*#?&",
            ]
        ),
        "marriott.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "$!#&@?%=",
            ]
        ),
        "maybank2u.com.my": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-~!@#$%^&*_+=`|(){}[:;\"'<>,.?",
            ],
            maxConsecutive: 2
        ),
        "medicare.gov": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@!$%^*()",
            ]
        ),
        "meineschufa.de": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!?#%$",
            ]
        ),
        "member.everbridge.net": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!@#$%^&*()",
            ]
        ),
        "metlife.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "microsoft.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "milogin.michigan.gov": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "@#$!~&",
            ]
        ),
        "mintmobile.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%&()*+:;=@[^_`{}~]",
            ]
        ),
        "mlb.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "mountainwarehouse.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-@#$%^&*_+={}|\\:',?/`~\"();.",
            ]
        ),
        "mpv.tickets.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "museumofflight.org": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "my.konami.net": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "myaccess.dmdc.osd.mil": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-@_#!&$`%*+()./,;~:{}|?>=<^'[]",
            ]
        ),
        "mybam.bcbsnm.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%&()*@[^{}~",
            ],
            maxConsecutive: 2
        ),
        "mygoodtogo.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "myhealthrecord.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "_.!$*=",
            ]
        ),
        "mypatientvisit.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*+.;?@^_~",
            ]
        ),
        "mypay.dfas.mil": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#@$%^!*+=_",
            ]
        ),
        "mysavings.breadfinancial.com": CustomPasswordGeneratorParams(
            length: 25,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "+_%@!$*~",
            ]
        ),
        "mysedgwick.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-~_$.,;",
                .required: "@#%^&+=!",
            ]
        ),
        "mysubaru.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%()*+,./:;=?@\\^`~",
            ]
        ),
        "naver.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "nekochat.cn": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "nelnet.net": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$&*",
            ]
        ),
        "netflix.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "netgear.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "!@#$%^&*()",
            ]
        ),
        "nowinstock.net": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "order.wendys.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%&()*+/=?^_{}",
            ]
        ),
        "ototoy.jp": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "- .=_",
            ]
        ),
        "packageconciergeadmin.com": CustomPasswordGeneratorParams(
            length: 4,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "pavilions.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "paypal.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()",
            ],
            maxConsecutive: 3
        ),
        "payvgm.youraccountadvantage.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "pilotflyingj.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "pixnet.cc": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "planetary.org": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "plazapremiumlounge.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%&*,@^",
            ]
        ),
        "portal.edd.ca.gov": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&()*@^",
            ]
        ),
        "portals.emblemhealth.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&'()*+,./:;<>?@\\^_`{|}~[]",
            ]
        ),
        "portlandgeneral.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%&*?@",
            ]
        ),
        "poste.it": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ],
            maxConsecutive: 2
        ),
        "posteo.de": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-~!#$%&_+=|(){}[:;\"’<>,.? ]",
            ]
        ),
        "powells.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "\"!@#$%^&*(){}[]",
            ]
        ),
        "preferredhotels.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&()*+@^_",
            ]
        ),
        "premier.ticketek.com.au": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "premierinn.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "prepaid.bankofamerica.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()+~{}'\";:<>?",
            ]
        ),
        "prestocard.ca": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!\"#$%&'()*+,<>?@",
            ]
        ),
        "pret.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .required: "@$!%*#?&",
            ]
        ),
        "promozoneapp.nmlottery.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "propelfuels.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "publix.com": CustomPasswordGeneratorParams(
            length: 28,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%*@^",
            ]
        ),
        "qdosstatusreview.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&@^",
            ]
        ),
        "questdiagnostics.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&()*+<>?@^_~",
            ]
        ),
        "randalls.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "rejsekort.dk": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "renaud-bray.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "ring.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*<>?",
            ]
        ),
        "riteaid.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "robinhood.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "rogers.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$",
            ]
        ),
        "ruc.dk": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!#%&(){}*+;%/<=>?_",
            ]
        ),
        "runescape.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "ruten.com.tw": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "safeway.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "salslimo.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$&*",
            ]
        ),
        "santahelenasaude.com.br": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%&*_+=<>",
            ]
        ),
        "santander.de": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!#$%&'()*,.:;=?^{}",
            ]
        ),
        "savemart.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .required: "!#$%&@",
            ]
        ),
        "sbisec.co.jp": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "secure-arborfcu.org": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&'()+,.:?@[_`~]",
            ]
        ),
        "secure.orclinic.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "secure.snnow.ca": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "sephora.com": CustomPasswordGeneratorParams(
            length: 12,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "serviziconsolari.esteri.it": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "servizioelettriconazionale.it": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*?@^_~",
            ]
        ),
        "sfwater.org": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "!@#$%*()_+^}{:;?.",
            ]
        ),
        "shaws.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "signin.ea.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!@#^&*=+;:",
            ]
        ),
        "sjwaterhub.com": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#%&*.",
            ]
        ),
        "southwest.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!@#$%^*(),.;:/\\",
            ]
        ),
        "speedway.com": CustomPasswordGeneratorParams(
            length: 8,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "spirit.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()",
            ]
        ),
        "splunk.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%&*_+=<>",
            ]
        ),
        "ssa.gov": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "~!@#$%^&*",
            ]
        ),
        "starmarket.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "store.nintendo.co.uk": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "store.nvidia.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%^*~:;&><[{}|_+=?]",
            ]
        ),
        "store.steampowered.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "~!@#$%^&*",
            ]
        ),
        "subscribe.free.fr": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#&()*+/@[_]",
            ]
        ),
        "successfactors.eu": CustomPasswordGeneratorParams(
            length: 18,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!\"#$%&'()*+,.:;<=>?@[^_`{|}~]",
            ]
        ),
        "sulamericaseguros.com.br": CustomPasswordGeneratorParams(
            length: 6,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "sunlife.com": CustomPasswordGeneratorParams(
            length: 10,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "t-mobile.net": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "target.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!\"#$%&'()*+,./:;=?@[\\^_`{|}~",
            ]
        ),
        "tdscpc.gov.in": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: " &',;\"",
            ]
        ),
        "telekom-dienste.de": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%&()*+,./<=>?@_{|}~",
            ]
        ),
        "thameswater.co.uk": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "themovingportal.co.uk": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-@#$%^&*_+={}|\\:',?/'~\" ();.[]",
            ]
        ),
        "ticketweb.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "tix.soundrink.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "tomthumb.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "training.confluent.io": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%*@^_~",
            ]
        ),
        "treasurer.mo.gov": CustomPasswordGeneratorParams(
            length: 26,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$&",
            ]
        ),
        "truist.com": CustomPasswordGeneratorParams(
            length: 28,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%()*,:;=@_",
            ],
            maxConsecutive: 2
        ),
        "turkishairlines.com": CustomPasswordGeneratorParams(
            length: 6,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            maxConsecutive: 3
        ),
        "twitch.tv": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "twitter.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "ubisoft.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%^&*()+",
            ]
        ),
        "udel.edu": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^&*()+",
            ]
        ),
        "umterps.evenue.net": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-~!@#$%^&*_+=`|(){}:;",
            ]
        ),
        "unito.it": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!?+*/:;'\"{}()@£$%&=^#[]",
            ]
        ),
        "user.ornl.gov": CustomPasswordGeneratorParams(
            length: 30,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "!#$%./_",
            ],
            maxConsecutive: 3
        ),
        "usps.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "-!\"#&'()+,./?@",
            ],
            maxConsecutive: 2
        ),
        "vanguard.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "vanguardinvestor.co.uk": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "ventrachicago.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%^",
            ]
        ),
        "verizonwireless.com": CustomPasswordGeneratorParams(
            length: 20,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "vetsfirstchoice.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .allowed: "?!@$%^+=&",
            ]
        ),
        "vince.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "$%/(){}=?!.,_*|+~#[]",
            ]
        ),
        "virginmobile.ca": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$@",
            ]
        ),
        "visa.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "visabenefits-auth.axa-assistance.us": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!\"#$%&()*,.:<>?@^{|}",
            ]
        ),
        "vivo.com.br": CustomPasswordGeneratorParams(
            length: 6,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            maxConsecutive: 3
        ),
        "volaris.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .required,
                .upperCase: .required,
            ]
        ),
        "vons.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*@^",
            ]
        ),
        "wa.aaa.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "walkhighlands.co.uk": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "walmart.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-(~!@#$%^&*_+=`|(){}[:;\"'<>,.?]",
            ]
        ),
        "waze.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "wccls.org": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "web.de": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-<=>~!|()@#{}$%,.?^'&*_+`:;\"[]",
            ]
        ),
        "wegmans.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&*+=?@^",
            ]
        ),
        "weibo.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .allowed,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ]
        ),
        "wellsfargo.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "wmata.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!@#$%^&*~/\"()_=+\\|,.?[]",
            ]
        ),
        "worldstrides.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "-!#$%&*+=?@^_~",
            ]
        ),
        "wsj.com": CustomPasswordGeneratorParams(
            length: 15,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .allowed,
            ],
            customLists: [
                .allowed: "-~!@#$^*_=`|(){}[:;\"'<>,.?]",
            ]
        ),
        "xfinity.com": CustomPasswordGeneratorParams(
            length: 16,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "xvoucher.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!@#$%&_",
            ]
        ),
        "yatra.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "!#$%&'()+,.:?@[_`~]",
            ]
        ),
        "yeti.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            customLists: [
                .required: "#$%*",
            ]
        ),
        "zara.com": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "zdf.de": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .allowed,
                .specials: .allowed,
                .upperCase: .required,
            ]
        ),
        "zoom.us": CustomPasswordGeneratorParams(
            length: 32,
            fixedSets: [
                .digits: .required,
                .lowerCase: .required,
                .specials: .allowed,
                .upperCase: .required,
            ],
            maxConsecutive: 6
        ),
    ]
}
