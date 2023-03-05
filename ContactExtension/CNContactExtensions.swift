//
//  CNContactExtensions.swift
//  ContactExtension
//
//  Created by PokeDuck on 2020/10/25.
//  Copyright © 2020 PokeDuck. All rights reserved.
//

import Contacts
import UIKit
@objc extension CNContact {
    open var rawData: Data? {
        var itemsCnt = 0

        // MARK: Begin

        let dev = UIDevice.current
        var vcfStr = String(format: "BEGIN:VCARD\nVERSION:3.0\nPRODID:-//Apple Inc.//\(dev.systemName) \(dev.systemVersion)//EN\n")

        // MARK: - Names

        // MARK: N

        vcfStr.append("N:\(familyName.cn())")
        vcfStr.append(";\(givenName.cn())")
        vcfStr.append(";\(middleName.cn())")
        vcfStr.append(";\(namePrefix.cn())")
        vcfStr.append(";\(nameSuffix.cn())\n")

        // MARK: FN

        switch contactType {
        case .person:
            if fn.count > 0 {
                vcfStr.append("FN:%@\(fn.cn())\n")
            }
        case .organization:
            if organizationName.count > 0 {
                vcfStr.append("FN:%@\(organizationName.cn())\n")
            }
        default:
            break
        }

        // MARK: NickName

        if nickname.count > 0 {
            vcfStr.append("NICKNAME:\(nickname.cn())\n")
        }

        // MARK: Note

        if note.count > 0 {
            vcfStr.append("NOTE:\(note.cn())\n")
        }

        // MARK: PreviousFamilyName

        if previousFamilyName.count > 0 {
            vcfStr.append("X-MAIDENNAME:\(previousFamilyName.cn())\n")
        }

        // MARK: Phonetic Given Name

        if phoneticGivenName.count > 0 {
            vcfStr.append("X-PHONETIC-FIRST-NAME:\(phoneticGivenName.cn())\n")
        }

        // MARK: Phonetic Middle Name

        if phoneticGivenName.count > 0 {
            vcfStr.append("X-PHONETIC-MIDDLE-NAME:\(phoneticMiddleName.cn())\n")
        }

        // MARK: Phonetic Family Name

        if phoneticGivenName.count > 0 {
            vcfStr.append("X-PHONETIC-LAST-NAME:\(phoneticFamilyName.cn())\n")
        }

        // MARK: Origanization Name

        if departmentName.count > 0 || organizationName.count > 0 {
            vcfStr.append("ORG:\(organizationName.cn());\(departmentName)\n")
        }

        // FIXME: CNContactSerialization decoder unsupport tag:'X-PHONETIC-ORG'
        if #available(iOS 10.0, *), phoneticOrganizationName.count > 0 {
            vcfStr.append("X-PHONETIC-ORG:\(phoneticOrganizationName.cn())\n")
        }

        // MARK: Job Title

        if jobTitle.count > 0 {
            vcfStr.append("TITLE:\(jobTitle.cn())\n")
        }

        // MARK: Emails

        for value: CNLabeledValue in emailAddresses {
            let pref = value.isEqual(emailAddresses.first) ? ";type=pref" : ""
            let label = value.label ?? CNLabelOther
            let value_ = (value.value as String).cn()
            switch label {
            case CNLabelEmailiCloud:
                itemsCnt += 1
                vcfStr.append("item\(itemsCnt).EMAIL;type=INTERNET\(pref):\(value_)\nitem\(itemsCnt).X-ABLabel:iCloud\n")
            case CNLabelHome:
                vcfStr.append("item\(itemsCnt).EMAIL;type=INTERNET;type=HOME\(pref):\(value_)\n")
            case CNLabelWork:
                vcfStr.append("item\(itemsCnt).EMAIL;type=INTERNET;type=WORK\(pref):\(value_)\n")
            case CNLabelOther:
                itemsCnt += 1
                vcfStr.append("item\(itemsCnt).EMAIL;type=INTERNET\(pref):\(value_)\nitem\(itemsCnt).X-ABLabel:_$!<Other>!$_\n")
            default:
                itemsCnt += 1
                vcfStr.append("item\(itemsCnt).EMAIL;type=INTERNET\(pref):\(value_)\nitem\(itemsCnt).X-ABLabel:\(label.cn())\n")
            }
        }

        // MARK: - Phone Number

        for value in phoneNumbers {
            let pref = value.isEqual(phoneNumbers.first) ? ";type=pref" : ""
            let label = value.label ?? CNLabelOther
            let number: CNPhoneNumber = (value.value as CNPhoneNumber)
            let value_ = number.stringValue.cn()
            switch label {
            case CNLabelHome:
                vcfStr.append("TEL;type=HOME;type=VOICE\(pref):\(value_)\n")
            case CNLabelWork:
                vcfStr.append("TEL;type=WORK;type=VOICE\(pref):\(value_)\n")
            case CNLabelOther:
                vcfStr.append("TEL;type=OTHER;type=VOICE\(pref):\(value_)\n")
            case CNLabelPhoneNumberiPhone:
                vcfStr.append("TEL;type=IPHONE;type=CELL;type=VOICE\(pref):\(value_)\n")
            case CNLabelPhoneNumberMobile:
                vcfStr.append("TEL;type=CELL;type=VOICE\(pref):\(value_)\n")
            case CNLabelPhoneNumberMain:
                vcfStr.append("TEL;type=MAIN\(pref):\(value_)\n")
            case CNLabelPhoneNumberHomeFax:
                vcfStr.append("TEL;type=HOME;type=FAX\(pref):\(value_)\n")
            case CNLabelPhoneNumberWorkFax:
                vcfStr.append("TEL;type=WORK;type=FAX\(pref):\(value_)\n")
            case CNLabelPhoneNumberOtherFax:
                vcfStr.append("TEL;type=OTHER;type=FAX\(pref):\(value_)\n")
            case CNLabelPhoneNumberPager:
                vcfStr.append("TEL;type=PAGER\(pref):\(value_)\n")
            default:
                itemsCnt += 1
                vcfStr.append("item\(itemsCnt).TEL\(pref):\(value_)\nitem\(itemsCnt).X-ABLabel:\(label.cn())\n")
            }
        }

        // MARK: Postal Address

        for address in postalAddresses {
            let pref = address.isEqual(postalAddresses.first) ? ";type=pref" : ""
            itemsCnt += 1
            let label = address.label ?? CNLabelOther
            let p = address.value
            let st = p.street.cn()
            let ct = p.city.cn()
            let ste = p.state.cn()
            let pc = p.postalCode.cn()
            let cnty = p.country.cn()
            var localLabel = ""
            var xABLavel = ""
            switch label {
            case CNLabelHome:
                localLabel = "HOME"
            case CNLabelWork:
                localLabel = "WORK"
            case CNLabelOther:
                localLabel = "OTHER"
            default:
                localLabel = label
                xABLavel = "item\(itemsCnt):X-ABLabel:\(label)\n"
            }
            vcfStr.append("item\(itemsCnt).ADR;type=\(localLabel)\(pref):;;\(st);\(ct)\(ste);\(pc);\(cnty)\n\(xABLavel)")
            if p.isoCountryCode.count > 0 {
                vcfStr.append(String(format: "item%d.X-ABADR:%@\n", itemsCnt, p.isoCountryCode.cn()))
            }
            if #available(iOS 10.3, *), p.subLocality.count > 0 {
                vcfStr.append("item\(itemsCnt).X-APPLE-SUBLOCALITY:\(p.subLocality.cn())\n")
            }
            if #available(iOS 10.3, *), p.subAdministrativeArea.count > 0 {
                vcfStr.append("item\(itemsCnt).X-APPLE-SUBADMINISTRATIVEAREA:\(p.subAdministrativeArea.cn())\n")
            }
        }

        // MARK: Social Profile

        for socialProfile in socialProfiles {
            let label = socialProfile.label ?? CNLabelOther
            let p = socialProfile.value
            var service = ""
            switch label {
            case CNSocialProfileServiceTencentWeibo:
                service = "JabberInstant"
            case CNSocialProfileServiceFacebook, CNSocialProfileServiceFlickr, CNSocialProfileServiceLinkedIn, CNSocialProfileServiceMySpace, CNSocialProfileServiceSinaWeibo:
                service = label.lowercased()
            default:
                service = label
                // cotain Yelp,Game Center
            }
            vcfStr.append("X-SOCIALPROFILE;type=\(service.cn());x-user=\(p.username.cn());x-userid=\(p.userIdentifier.cn()):\(p.urlString.cn())\n")

            // X-SOCIALPROFILE;type=%@;x-userid=%@:x-apple:%@\n -> 內建的服務
        }

        // MARK: Web_Page

        for page in urlAddresses {
            let pref = page.isEqual(urlAddresses.first) ? ";type=pref" : ""
            let label = page.label ?? CNLabelOther
            let value = page.value as String
            switch label {
            case CNLabelHome:
                vcfStr.append("URL;type=HOME\(pref):\(value.cn())\n")
            case CNLabelWork:
                vcfStr.append("URL;type=WORK\(pref):\(value.cn())\n")
            default:
                itemsCnt += 1
                vcfStr.append("item\(itemsCnt).URL\(pref):\(value.cn())\nitem\(itemsCnt).X-ABLabel:\(label.cn())\n")
            }
        }

        // MARK: - IM

        // MARK: Tag

        var hasAIM = false
        var hasJABBER = false
        var hasMSN = false
        var hasYAHOO = false
        var hasICQ = false
        for im in instantMessageAddresses {
            let label = im.label ?? CNLabelOther
            let imAddr: CNInstantMessageAddress = im.value
            let service = imAddr.service
            let name = imAddr.username
            // HOME:account :Twitter
            // 先定義label 再定義service
            var tag = ""
            var pref = ""
            switch service {
            case CNInstantMessageServiceAIM:
                tag = "X-AIM"
                guard hasAIM else {
                    pref = ";type=pref"
                    hasAIM = true
                    break
                }
            case CNInstantMessageServiceJabber:
                tag = "X-JABBER"
                guard hasJABBER else {
                    pref = ";type=pref"
                    hasJABBER = true
                    break
                }
            case CNInstantMessageServiceMSN:
                tag = "X-MSN"
                guard hasMSN else {
                    pref = ";type=pref"
                    hasMSN = true
                    break
                }
            case CNInstantMessageServiceYahoo:
                tag = "X-YAHOO"
                guard hasYAHOO else {
                    pref = ";type=pref"
                    hasYAHOO = true
                    break
                }
            case CNInstantMessageServiceICQ:
                tag = "X-ICQ"
                guard hasICQ else {
                    pref = ";type=pref"
                    hasICQ = true
                    break
                }
            default:
                continue
            }
            var cnLabel = ""
            var xLabel = ""
            var tagLabel = ""

            switch label {
            case CNLabelHome:
                cnLabel = ";type=HOME"
            case CNLabelWork:
                cnLabel = ";type=WORK"
            default:
                itemsCnt += 1
                tagLabel = "item\(itemsCnt)."
                xLabel = "item\(itemsCnt).X-ABLabel:\(label.cn())\n"
            }
            vcfStr.append("\(tagLabel)\(tag)\(cnLabel)\(pref):\(name.cn())\n\(xLabel)")
        }

        // MARK: Protocol -IMPP

        for im in instantMessageAddresses {
            let label = im.label ?? CNLabelOther
            let imAddr: CNInstantMessageAddress = im.value
            let service = imAddr.service.uppercased()
            let name = imAddr.username
            let pref = im.isEqual(instantMessageAddresses.first) ? ";type=pref" : ""
            // HOME:account :Twitter
            // 先定義label 再定義service
            var prtclNm = ""
            switch service {
            case CNInstantMessageServiceAIM, CNInstantMessageServiceICQ:
                prtclNm = "aim"
            case CNInstantMessageServiceGaduGadu, CNInstantMessageServiceQQ:
                prtclNm = "x-apple"
            case CNInstantMessageServiceMSN:
                prtclNm = "msnim"
            case CNInstantMessageServiceSkype:
                prtclNm = "skype"
            case CNInstantMessageServiceYahoo:
                prtclNm = "ymsgr"
            default:
                prtclNm = "xmpp"
            }
            let serviceU = service.uppercased()
            let utf8Name = name.cn().addingPercentEncoding(withAllowedCharacters: .uppercaseLetters) ?? "other"
            var cnLabel = ""
            var tagLabel = ""
            var xLabel = ""
            switch label {
            case CNLabelHome:
                cnLabel = ";type=HOME"
            case CNLabelWork:
                cnLabel = ";type=WORK"
            default:
                itemsCnt += 1
                tagLabel = "item\(itemsCnt)."
                xLabel = "item\(itemsCnt).X-ABLabel:\(label.cn())\n"
            }
            vcfStr.append("\(tagLabel)IMPP;X-SERVICE-TYPE=\(serviceU)\(cnLabel)\(pref):\(prtclNm):\(utf8Name)\n\(xLabel)")
        }

        // MARK: -

        // MARK: BirthDay

        if let bDay = birthday,
           let y = bDay.year,
           let m = bDay.month,
           let d = bDay.day
        {
            vcfStr.append(String(format: "BDAY:%04d-%02d-%02d\n", y, m, d))
        }

        // MARK: Anniversary Date

        for date in dates {
            let label = date.label ?? "Date"
            let dateCpnt = date.value
            let y = dateCpnt.year
            let m = dateCpnt.month
            let d = dateCpnt.day
            itemsCnt += 1
            switch label {
            case CNLabelDateAnniversary:
                vcfStr.append(String(format: "item%d.X-ABDATE;type=pref:%04d-%02d-%02d\nitem%d.X-ABLabel:_$!<Anniversary>!$_\n", itemsCnt, y, m, d, itemsCnt))
            default:
                vcfStr.append(String(format: "item%d.X-ABDATE:%04d-%02d-%02d\nitem%d.X-ABLabel:%@\n", itemsCnt, y, m, d, itemsCnt, label.cn()))
            }
        }

        // MARK: Alter Date

        if let dateCpnt = nonGregorianBirthday,
           let calId = dateCpnt.calendar?.identifier,
           let y = dateCpnt.year,
           let m = dateCpnt.month,
           let d = dateCpnt.day
        {
            switch calId {
            case Calendar.Identifier.chinese:
                // B.C.2698 = 黃帝元年(黃曆)https://goo.gl/1oTYg5
                // A.D.2018 = 黃帝4716年
                // chinese value 004400580101 -> 1年辛酉年正月初一
                // chinese value 007800010101 -> 1984年甲子正月初一
                // chinese value 007700600101 -> 1983年癸亥正月初一
                // 1983/60 = 33...3
                // 1984/60 = 33...4 > 44 + 33 + ((58+4-1)/60) = 0078
                guard let date = dateCpnt.date else {
                    break
                }
                let yInt = Int(date.y()) ?? 2018
                let cnY = yInt / 60 + 44 + (58 + yInt % 60 - 1) / 60
                vcfStr.append(String(format: "X-ALTBDAY;CALSCALE=chinese:%04d%04d%02d%02d\n", cnY, y, m, d))
            case .islamic:
                vcfStr.append(String(format: "X-ALTBDAY;CALSCALE=islamic:-%4d%02d%02d\n", y, m, d))
            case .hebrew:
                vcfStr.append(String(format: "X-ALTBDAY;CALSCALE=hebrew:-%4d%02d%02d\n", y, m, d))
            default:
                print("nothing")
            }
        }

        // MARK: Relation

        for rel in contactRelations {
            let pref = rel.isEqual(contactRelations.first) ? ";type=pref" : ""
            itemsCnt += 1
            let label = rel.label ?? CNLabelOther
            let name = rel.value.name
            vcfStr.append("item\(itemsCnt).X-ABRELATEDNAMES\(pref):\(name.cn())\nitem\(itemsCnt).X-ABLabel:\(label.cn())\n")
        }

        // MARK: Image - Base64

        if let img = imageData {
            vcfStr.append(String(format: "PHOTO;ENCODING=b:%@\n", img.base64EncodedString()))
        }

        // MARK: Company

        if contactType == .organization {
            vcfStr.append("X-ABShowAs:COMPANY\n")
        }

        // MARK: Rington Alert

        // TODO: Rington
        // vcfStr.append(String(format:"X-ACTIVITY-ALERT:type=call\\,snd=system:Bulletin\\,vib=Alert\n"))
        // vcfStr.append(String(format:"X-ACTIVITY-ALERT:type=text\\,snd=<none>\n"))

        // MARK: ContactID

        // TODO: CNContactSerialization decoder unsupport tag:'X-ABUID'
        vcfStr.append("X-ABUID:\(identifier.cn())\n")
        vcfStr.append(String(format: "X-ABUID:%@:ABPerson\n", identifier.cn()))

        // MARK: End

        vcfStr.append("END:VCARD")
        print(self)
        return vcfStr.data(using: .utf8)
    }
}

extension CNContact {
    override open var description: String {
        return displayName
    }

    fileprivate var displayName: String {
        var name: String = namePrefix + givenName + middleName + familyName + nameSuffix
        if name.count <= 0 {
            if urlAddresses.count > 0 {
                name = emailAddresses[0].value as String
            } else if socialProfiles.count > 0 {
                name = socialProfiles.first?.value.username ?? "NoName"
            } else if instantMessageAddresses.count > 0 {
                name = instantMessageAddresses.first?.value.username ?? "NoName"
            } else if phoneNumbers.count > 0 {
                name = phoneNumbers[0].value.stringValue
            } else {
                name = "NoName"
            }
        }
        return name
    }

    var fn: String {
        var name: String = ""
        if namePrefix.count > 0 {
            if name.count > 0 { name += " " }
            name += namePrefix
        }
        if givenName.count > 0 {
            if name.count > 0 { name += " " }
            name += givenName
        }
        if middleName.count > 0 {
            if name.count > 0 { name += " " }
            name += middleName
        }
        if familyName.count > 0 {
            if name.count > 0 { name += " " }
            name += familyName
        }
        if nameSuffix.count > 0 {
            if name.count > 0 { name += " " }
            name += nameSuffix
        }
        return name
    }
}

extension String {
    static let willSlashN: String = UUID().uuidString
    static let willSlashR: String = UUID().uuidString
    func cn() -> String {
        var tempStr = replacingOccurrences(of: "\\r", with: String.willSlashR)
        tempStr = tempStr.replacingOccurrences(of: "\\n", with: String.willSlashN)
        tempStr = tempStr.replacingOccurrences(of: "\r", with: "\\r")
        tempStr = tempStr.replacingOccurrences(of: "\n", with: "\\n")
        tempStr = tempStr.replacingOccurrences(of: String.willSlashR, with: "\\\\r")
        tempStr = tempStr.replacingOccurrences(of: String.willSlashN, with: "\\\\n")
        return tempStr
    }
}

private let sharedDateFormatter = DateFormatter()
extension Date {
    func dateComponents(calId: Calendar.Identifier) -> DateComponents {
        let cnCal = Calendar(identifier: calId)
        // chinese value 007800010101 -> 1984年甲子正月初一

        // 取得農曆生肖
        // 用這個DateComponent加入Contact會失敗
        var cnDate = cnCal.dateComponents(Set(arrayLiteral: .year, .month, .day), from: self)

        // 再轉一次
        cnDate = DateComponents(calendar: cnCal,
                                year: cnDate.year,
                                month: cnDate.month,
                                day: cnDate.day)
        return cnDate
    }

    var stringFromNow: String {
        let formatter = sharedDateFormatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        formatter.locale = NSLocale.current
        let str = formatter.string(from: self)
        return str
    }

    func y() -> String {
        let fmt = sharedDateFormatter
        fmt.dateFormat = "yyyy"
        fmt.timeZone = TimeZone.current
        fmt.locale = NSLocale.current
        let str = fmt.string(from: self)
        return str
    }

    func month() -> String {
        let fmt = sharedDateFormatter
        fmt.dateFormat = "MM"
        fmt.timeZone = TimeZone.current
        fmt.locale = NSLocale.current
        let str = fmt.string(from: self)
        return str
    }

    func day() -> String {
        let fmt = sharedDateFormatter
        fmt.dateFormat = "dd"
        fmt.timeZone = TimeZone.current
        fmt.locale = NSLocale.current
        let str = fmt.string(from: self)
        return str
    }
}
