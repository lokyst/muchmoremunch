MMMunch = LibStub("AceAddon-3.0"):NewAddon("MMMunch", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MMMunch", true)

local PLACEHOLDER_CATEGORIES = {
    hpp = {
        "Consumable.Potion.Recovery.Healing.Basic",
        "Consumable.Potion.Recovery.Rejuvenation",
        "Consumable.Potion.Recovery.Health.Anywhere",
        "MMMunch.mmmExtraHealthPots.Conjured",
        "MMMunch.mmmExtraHealthPots",
    },
    mpp = {
        "Consumable.Potion.Recovery.Mana.Basic",
        "Consumable.Potion.Recovery.Rejuvenation",
        "Consumable.Potion.Recovery.Mana.Anywhere",
        "MMMunch.mmmExtraManaPots.Conjured",
        "MMMunch.mmmExtraManaPots",
    },
    hps = {
        "Consumable.Warlock.Healthstone",
        "MMMunch.mmmExtraHealthStone.Conjured",
        "MMMunch.mmmExtraHealthStone",
    },
    mps = {
        "Consumable.Cooldown.Stone.Mana.Mana Stone",
        "MMMunch.mmmExtraManaPots.Conjured",
        "MMMunch.mmmExtraManaPots",
        },
    hpf = {
        "MMM.Consumable.Food.Combo.Conjured", -- conjured + health and mana
        "MMM.Consumable.Food.Basic.Conjured", -- conjured + health
        "MMM.Consumable.Food.Buff.Combo.Conjured", -- conjured + health and mana + buff
        "MMM.Consumable.Food.Buff.Basic.Conjured", -- conjured + health + buff
        "MMM.Consumable.Food.Buff.Combo.Non-Conjured", -- health and mana + buff
        "MMM.Consumable.Food.Buff.Basic.Non-Conjured", -- health + buff
        "MMM.Consumable.Food.Combo.Non-Conjured", -- health and mana
        "MMM.Consumable.Food.Basic.Non-Conjured", -- health
        "MMMunch.mmmExtraFoods.Conjured",
        "MMMunch.mmmExtraFoods",
    },
    mpf = {
        "MMM.Consumable.Food.Combo.Conjured.Mana", -- conjured + health and mana
        "MMM.Consumable.Food.Basic.Conjured.Mana", -- conjured + mana
        "MMM.Consumable.Food.Buff.Combo.Conjured.Mana", -- conjured + health and mana + buff
        "MMM.Consumable.Food.Buff.Basic.Conjured.Mana", -- conjured + mana + buff
        "MMM.Consumable.Food.Buff.Combo.Non-Conjured.Mana", -- health and mana + buff
        "MMM.Consumable.Food.Buff.Basic.Non-Conjured.Mana", -- mana + buff
        "MMM.Consumable.Food.Combo.Non-Conjured.Mana", -- health and mana
        "MMM.Consumable.Food.Basic.Non-Conjured.Mana", -- mana
        "MMMunch.mmmExtraDrinks.Conjured",
        "MMMunch.mmmExtraDrinks",
    },
    b = {
        "Consumable.Bandage.Basic",
        "MMMunch.mmmExtraBandages.Conjured",
        "MMMunch.mmmExtraBandages",
    },
}

local PRESET_MACROS = {
    ["mHP"] = "#showtooltip\n/castsequence [nocombat] reset=120 <hps,hpp,hpp>\n"..
              "/castsequence [combat] reset=combat <hps,hpp>",
    ["mMP"] = "#showtooltip\n/use <mpp>",
    ["mFood"] = "#showtooltip\n/use <hpf>",
    ["mWater"] = "#showtooltip\n/use <mpf>",
    ["mBandage"] = "#showtooltip\n/use [@player] <b>",
    ["mAllHP"] = "#showtooltip\n/use [mod,@player] <b>; [nocombat] <hpf>\n/castsequence [nomod,combat] reset=combat <hps,hpp>",
    ["mAllMP"] = "#showtooltip\n/use [nomod,nocombat] <mpf>\n/castsequence [nomod,combat] reset=combat <mps,mpp>",
}

local buffList = {
    ["None"] = "None",
    ["Agility"] = "Agility",
    ["Attack Power"] = "Attack Power",
    ["Critical Rating"]= "Critical Rating",
    ["Dodge"] = "Dodge",
    ["Expertise"] = "Expertise",
    ["Haste Rating"] = "Haste Rating",
    ["Healing"] = "Healing",
    ["Hit Rating"] = "Hit Rating",
    ["HP Regen"] = "HP Regen",
    ["Intellect"] = "Intellect",
    ["Mana Regen"] = "Mana Regen",
    ["Mastery"] = "Mastery",
    ["Parry"] = "Parry",
    ["Spell Damage"] = "Spell Damage",
    ["Spirit"] = "Spirit",
    ["Stamina"] = "Stamina",
    ["Strength"] = "Strength",
}

local itemTypeList = {
    ["None"] = "None",
    ["Health Potion"] = "Health Potion",
    ["Health Stone"] = "Health Stone",
    ["Mana Potion"] = "Mana Potion",
    ["Mana Stone"] = "Mana Stone",
    ["Health Food"] = "Health Food",
    ["Mana Food"] = "Mana Food",
    ["Bandage"] = "Bandage",
}

local options = {
    name = "MuchMoreMunch",
    handler = MMMunch,
    type = 'group',
    args = {
        general = {
            name = L['General'],
            type = 'group',
            args = {
                newMacro = {
                    name = L['New Macro'],
                    type = 'input',
                    desc = L['Create a new empty macro'],
                    set = 'SetNewMacro',
                    get = 'GetNewMacro',
                    order = 10,
                },
                macroSelectBox = {
                    name = L['Existing Macros'],
                    type = 'select',
                    desc = L['Select a macro to edit'],
                    set = 'SetSelectMacro',
                    get = 'GetSelectMacro',
                    style = 'dropdown',
                    values = {},
                    order = 20,
                },
                macroName = {
                    name = L['Macro Name'],
                    type = 'input',
                    desc = L['Macro being edited'],
                    set = 'SetMacroName',
                    get = 'GetMacroName',
                    width = 'full',
                    order = 30,
                },
                macroEditBox = {
                    name = L['Macro Text'],
                    type = 'input',
                    desc = L['Edit your macro. Valid placeholders are:\n\n<hpp> - health potions\n<hps> - healthstones\n<mpp> - mana potions\n<mps> - mana gems\n<hpf> - health food\n<mpf> - mana food\n<b> - bandage\n\nMultiple placeholders can be combined for use in a castsequence, e.g. <hps,hpp>'],
                    set = 'SetMacroBody',
                    get = 'GetMacroBody',
                    multiline = true,
                    width = 'full',
                    order = 32
                },

                macroDeleteBox = {
                    name = L['Delete macro'],
                    type = 'select',
                    desc = L['Select a macro to be deleted'],
                    set = 'SetMacroDelete',
                    get = 'GetMacroDelete',
                    style = 'dropdown',
                    values = {},
                    order = 40,
                    confirm = true,
                    confirmText = L['Are you sure you wish to delete the selected macro?']
                },

                previewHeader = {
                    name = L['Preview Macro'],
                    type = 'header',
                    order = 50,
                },

                previewBody = {
                    name = '\n\n\n\n\n',
                    type = 'description',
                    order = 60,
                },

                blank1 = {
                    name = '',
                    type = 'header',
                    order = 100
                },

                createMacro = {
                    name = L['Create Macro'],
                    type = 'execute',
                    desc = L['Creates a macro that can be dragged onto your action bar'],
                    func = 'CreateMacro',
                    disabled = true,
                    order = 110,
                    width = 'full',
                },


            },
        },

        buffPreferences = {
            name = 'Buff Preferences',
            type = 'group',
            args = {

                maintainWellFed = {
                    name = 'Maintain Well Fed Buff',
                    type = 'toggle',
                    desc = 'Prioritize buff food when no Well Fed buff is present',
                    set = 'SetMaintainWellFed',
                    get = 'GetMaintainWellFed',
                    width = 'full',
                    order = 1,
                },


                buffSelectBox1 = {
                    name = 'Primary Buff',
                    type = 'select',
                    desc = 'Select Buff 1',
                    set = 'SetBuff1',
                    get = 'GetBuff1',
                    style = 'dropdown',
                    values = buffList,
                    order = 10,
                },

                buffSelectBox2 = {
                    name = 'Secondary Buff',
                    type = 'select',
                    desc = 'Select Buff 2',
                    set = 'SetBuff2',
                    get = 'GetBuff2',
                    style = 'dropdown',
                    values = buffList,
                    order = 20,
                },

                buffSelectBox3 = {
                    name = 'Tertiary Buff',
                    type = 'select',
                    desc = 'Select Buff 3',
                    set = 'SetBuff3',
                    get = 'GetBuff3',
                    style = 'dropdown',
                    values = buffList,
                    order = 30,
                },

            },
        },

        userAddedItems = {
            name = 'User Added Items',
            type = 'group',
            args = {

                itemTypeSelectBox = {
                    name = 'Item Type',
                    type = 'select',
                    desc = 'Select Item Type',
                    set = 'SetAddItemType',
                    get = 'GetAddItemType',
                    style = 'dropdown',
                    values = itemTypeList,
                    order = 30,
                },

                itemIsConjured = {
                    name = 'Conjured Item',
                    type = 'toggle',
                    desc = 'Item is conjured',
                    set = 'SetConjuredItem',
                    get = 'GetConjuredItem',
                    --width = 'full',
                    order = 40,
                },

                itemID = {
                    name = 'Item ID',
                    type = 'input',
                    desc = 'Item ID as obtained from WowHead or some siimilar database',
                    set = 'SetItemId',
                    get = 'GetItemId',
                    --width = 'half',
                    order = 10,
                },

                itemValue = {
                    name = 'Item Value',
                    type = 'input',
                    desc = 'How much HP, MP or points the item returns',
                    set = 'SetItemValue',
                    get = 'GetItemValue',
                    --width = 'half',
                    order = 20,
                },

                addItemButton = {
                    name = 'Add Item',
                    type = 'execute',
                    desc = 'Adds the new item to the selected category',
                    func = 'CreateItem',
                    order = 110,
                    width = 'full',
                },

                itemDeleteBox = {
                    name = 'Delete Item',
                    type = 'select',
                    desc = 'Select an item to be deleted',
                    set = 'SetItemDelete',
                    get = 'GetItemDelete',
                    style = 'dropdown',
                    values = {},
                    order = 140,
                    confirm = true,
                    confirmText = 'Are you sure you wish to delete the selected item? This action requires a reloadui to take effect.'
                },
            },
        },

    },
}

local defaults = {
    profile = {
        macroTable = {},
        buffPriority = {"None", "None", "None"},
        maintainWellFed = false,
        itemList = {},
        ["Health Potion"] = {},
        ["Health Stone"] = {},
        ["Mana Potion"] = {},
        ["Mana Stone"] = {},
        ["Health Food"] = {},
        ["Mana Food"] = {},
        ["Bandage"] = {},
    },
}

local PT = LibStub("LibPeriodicTable-3.1")

-- Add any missing items with a custom set
-- Remember to add custom set name to PLACEHOLDER_CATEGORIES
PT:AddData("MMMunch.mmmExtraBandages", "")
PT:AddData("MMMunch.mmmExtraFoods","")
PT:AddData("MMMunch.mmmExtraFoods.Conjured","")
PT:AddData("MMMunch.mmmExtraDrinks","")
PT:AddData("MMMunch.mmmExtraDrinks.Conjured","")
PT:AddData("MMMunch.mmmExtraHealthPots","89640:120000")
PT:AddData("MMMunch.mmmExtraManaPots","89641:30000")
PT:AddData("MMMunch.mmmExtraHealthStone","")
PT:AddData("MMMunch.mmmExtraManaStone","")

-- Autoscraped by dOxxx's Spatula
PT:AddData("MMM.Consumable.Food.Basic.Non-Conjured","44607:22500,49253:94,4538:825,34747:22500,111842:25000,6299:45,46796:94,82450:200000,1707:1215,18632:1215,81917:200000,69243:18480,111456:170000,67363:94,17119:365,13933:3216,115352:170000,82449:300000,733:825,20857:94,8952:3216,24338:3216,58262:67500,24009:6474,67379:94,74609:22500,35947:22500,44855:94,86057:200000,29450:7500,67375:94,117471:170000,46797:94,24072:365,33443:18480,67373:94,49603:365,67378:94,74921:96000,60375:94,2070:94,4599:2082,35953:22500,16168:2082,8953:3216,1326:365,67380:94,33452:18480,115353:170000,18633:365,67374:94,21552:2082,85504:200000,42431:22500,19224:1215,60379:94,35949:18480,58268:67500,2679:94,44940:22500,67362:94,4537:365,44608:18480,4536:94,40358:18480,4544:1215,74641:300000,81889:200000,67230:365,24008:6474,40202:22500,58269:96000,4539:1215,11951:1201,67367:94,28486:6474,41751:6474,46690:94,81918:300000,60377:94,63694:825,40356:18480,58277:22500,16167:365,67382:94,19305:825,33454:18480,13929:1312,81920:300000,4656:94,35952:22500,2685:825,4601:2082,62676:67500,105708:30000,19304:365,67372:94,90135:300000,117:94,23495:94,42429:22500,5095:365,4607:1215,58263:96000,117473:170000,33048:7500,30355:7500,13932:1312,44722:22500,18255:2082,117470:170000,32686:7500,67376:94,27854:6474,62909:365,422:825,9681:2082,117474:170000,81919:200000,5066:365,44071:22500,57518:825,21033:3216,21031:3216,8950:3216,67377:94,81175:200000,82451:300000,13546:2082,115355:170000,4606:825,8364:1215,44609:18480,42433:18480,60378:94,67273:3216,13928:1312,88398:300000,67381:94,3927:2082,59228:67500,13934:6474,6290:94,29451:7500,4592:365,33449:18480,81916:300000,67365:94,19306:2082,13931:1312,37252:18480,4540:94,117457:170000,58279:22500,11415:3216,67270:3216,4541:365,4608:2082,42778:22500,117469:170000,69244:2082,37452:18480,414:365,58266:67500,5526:825,67383:94,16171:3216,4602:2082,2287:365,29448:7500,5478:825,67368:94,65730:825,32685:7500,67272:3216,42430:18480,44854:94,27857:6474,83097:200000,46784:94,117454:170000,7228:825,28501:6474,35565:2905,112095:365,67364:94,19223:94,5057:94,67361:94,58261:96000,23160:3228,8932:3216,27856:6474,19225:3216,4542:825,787:94,60268:94,65731:825,67384:94,6890:365,67369:94,4605:365,67271:3216,58264:67500,3770:825,16166:94,29394:7500,81922:200000,59231:22500,29449:7500,13755:1215,35951:22500,44072:22500,21030:2082,73260:96000,41729:22500,58265:96000,4594:1215,27855:6474,58278:22500,6887:2082,29452:7500,44049:22500,58260:67500,58275:22500,13810:2894,12238:365,16170:825,59232:67500,81921:300000,13930:2082,49397:365,67371:94,63693:825,30816:94,62677:96000,63691:2082,17344:94,58280:22500,13927:1312,67366:94,29412:6474,38706:22500,113290:170000,16169:1215,13893:2082,35948:22500,62910:825,57544:94,59227:22500,44749:18480,6316:365,29393:6474,60267:94,3771:1215,18254:2894,16766:2082,27859:6474,58258:67500,63692:1215,67370:94,2681:94,7097:94,116120:221000,11109:45,42432:18480,13935:3216,17406:365,22324:3216,35950:22500,18635:2082,115354:170000,40359:18480,27661:6474,8948:3216,30458:6474,17407:1215,33451:18480,49600:365,45901:22500,38428:7500,6807:1215,38427:6474,58259:96000,46793:94,42428:18480,8957:3216,82448:200000,58276:22500,115351:170000,11444:3216,27858:6474,117472:170000,30610:6474,4604:94,17408:2082,69920:365,42434:22500,29453:7500,61383:1215,49361:365,58267:96000,4593:825,43087:22500,961:94")
PT:AddData("MMM.Consumable.Food.Combo.Non-Conjured","3448:441,20031:4320,68687:67500,98116:20000,111544:170000,112449:300000,19301:6612,75038:300000,108920:300000,43478:22500,34759:22500,34760:22500,86026:200000,104196:20000,2682:441,118424:170000,43480:22500,98111:20000,98118:20000,28112:6612,87253:300000,34761:22500,75026:200000,34780:7500,33053:7500,13724:3216,32722:4320,45932:45000")
PT:AddData("MMM.Consumable.Food.Combo.Conjured","65499:96000,80610:300000,34062:7500,80618:300000,65500:1458,65515:2082,65516:3216,43518:18480,43523:67500,65517:6474")
PT:AddData("MMM.Consumable.Food.Basic.Conjured.Mana","2136:835,8079:4200,3772:1345,8078:2934,5350:151,2288:437,8077:1992,30703:5100,22018:7200")
PT:AddData("MMM.Consumable.Food.Combo.Conjured.Mana","65499:96000,80610:300000,65500:1494,65516:2934,80618:300000,34062:7200,65515:1992,43523:45000,43518:12840,65517:4200")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Non-Conjured.Mana","74651:200000,89600:13000,60858:45000,62664:96000,62656:45000,89599:7200,111452:170000,101618:30000,89592:7200,62667:96000,79320:120000,74649:300000,74650:300000,62649:96000,43015:19200,34769:19200,101749:30000,89588:650,62657:45000,111450:170000,34767:19200,88586:200000,62654:45000,111445:170000,62658:45000,86070:300000,74644:200000,81414:300000,89590:3000,101745:30000,21254:298800,43000:19200,62660:45000,89595:650,34763:19200,74645:300000,62653:45000,34766:19200,74655:300000,62663:96000,34762:19200,34753:19200,89598:4200,118428:170000,62671:96000,111447:170000,101746:30000,111437:170000,89597:3000,101747:30000,111442:170000,111454:170000,111441:170000,42993:19200,62651:45000,86069:300000,21217:1260,111436:170000,33004:2934,62662:96000,62655:45000,74642:100000,111453:170000,62665:96000,62666:96000,111446:170000,43268:19200,44953:19200,89601:45000,111449:170000,74656:300000,120293:170000,111434:170000,62659:45000,88388:150000,34768:19200,101750:30000,42996:19200,111433:170000,62669:96000,74643:200000,86073:300000,62668:96000,34765:19200,62661:96000,111439:170000,34764:19200,111444:170000,81406:200000,105721:300000,74647:300000,89594:45000,101617:30000,89596:2000,118416:170000,42942:19200,74646:300000,74648:300000,89593:13000,42998:19200,62652:45000,111438:170000,94535:300000,89591:4200,62670:96000,74653:300000,90457:200000,111431:170000,101748:30000,101616:30000,74654:200000,98127:300000,74652:300000,21072:567,46691:298800,42999:19200,89589:2000,86074:300000,45279:19200")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Conjured","70924:120000,70925:120000,118268:170000,118270:170000,118269:170000,118272:170000,118271:170000,70927:120000,70926:120000")
PT:AddData("MMM.Consumable.Food.Basic.Non-Conjured.Mana","59229:19200,74822:96000,63530:437,40357:7200,117475:170000,19300:1992,49398:437,49601:437,33445:19200,43236:19200,105703:30000,9451:835,88578:200000,30457:7200,1645:1992,75037:150000,105701:30000,19299:835,1179:437,28399:5100,58274:19200,159:151,27860:7200,74636:300000,105700:30000,38430:5100,34411:7200,49602:437,4791:1345,61382:1345,60269:151,33825:7200,105705:30000,49254:151,37253:7200,35954:7200,105711:30000,59230:45000,32455:4200,59029:45000,111455:170000,68140:96000,38698:12840,117452:170000,29401:7200,58257:96000,105702:30000,18300:4200,33042:7200,63023:1992,32668:7200,42777:19200,105704:30000,90660:835,105707:30000,38429:2934,81923:300000,10841:1345,38431:7200,41731:19200,29395:7200,33444:12840,63251:96000,32453:7200,88532:300000,1708:1345,90659:437,43086:12840,1205:835,120168:170000,105706:30000,58256:45000,81924:200000,44750:7200,62675:96000,85501:200000,8766:2934,29454:5100,17404:437,44941:12840,49365:437")
PT:AddData("MMM.Consumable.Food.Buff.Basic.Non-Conjured","27651:4320,81409:300000,105719:300000,81400:200000,5472:93,1017:825,81408:300000,104344:30000,105722:300000,29292:3216,105720:300000,33867:4320,27655:4320,31672:7500,77264:61,2684:365,57519:93,27666:7500,27635:93,27659:7500,34751:22500,3665:825,724:365,7806:93,98124:300000,33052:7500,42779:18480,35563:2905,16971:2082,98125:300000,98122:300000,34752:22500,18045:2082,27665:7500,81410:300000,81403:300000,104339:30000,5476:365,20452:3216,12213:1312,6038:1312,2687:365,27658:7500,3727:825,5477:365,7807:93,12215:2082,46392:825,5479:825,23756:93,12214:1312,5525:365,1082:825,105723:300000,42994:22500,12224:93,2888:93,33872:7500,12210:1312,22645:365,27657:7500,81412:300000,3729:1312,34748:22500,81402:200000,34125:22500,34749:22500,3666:825,27667:7500,30361:7500,43001:22500,34757:22500,2683:365,88379:200000,34750:22500,34756:22500,42995:22500,104343:30000,81413:300000,17197:93,27662:4320,81411:300000,3728:1312,20074:1312,12209:825,105717:300000,81405:200000,6888:93,31673:7500,105724:300000,17222:2082,77273:61,104341:30000,98121:300000,3662:365,27663:4320,27664:7500,7808:93,12218:2082,13851:1312,77272:61,30359:7500,3726:825,17198:93,27636:365,12216:2082,39691:22500,34755:22500,98123:300000,5527:825,34754:22500,34758:22500,21023:4320,11584:93,32721:6000,81404:200000,4457:1312,3663:825,2680:93,30358:7500,104342:30000,5474:93,3220:365,27660:7500,98126:300000,104340:30000,81401:200000,24105:93,3664:825,12212:1312,30155:4320,24539:4320,30357:7500,42997:22500,5480:825,64641:1312")
PT:AddData("MMM.Consumable.Food.Combo.Non-Conjured.Mana","3448:441,43478:19200,98116:20000,111544:170000,112449:300000,108920:300000,68687:45000,75038:150000,86026:200000,104196:20000,34761:19200,2682:441,20031:4410,43480:19200,118424:170000,34780:7200,98111:20000,98118:20000,33053:7200,87253:300000,19301:4410,28112:4410,75026:200000,34760:19200,45932:38400,13724:4410,34759:19200,32722:5100")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Non-Conjured","74651:200000,62664:96000,89588:1300,33004:3228,111452:170000,89592:7500,101618:30000,62667:96000,79320:120000,74649:300000,88388:300000,74650:300000,62649:96000,89593:19000,101749:30000,43015:22500,62655:67500,89595:1300,62651:67500,89599:7500,42942:22500,111450:170000,60858:67500,34765:22500,88586:200000,111445:170000,89591:6500,86070:300000,43000:22500,62660:67500,74642:200000,74644:200000,81414:300000,89598:6500,89590:3000,101745:30000,21254:298800,89600:19000,74645:300000,44953:22500,34753:22500,74655:300000,62663:96000,42993:22500,43268:22500,62658:67500,118428:170000,34763:22500,62671:96000,111447:170000,101746:30000,111437:170000,89597:3000,42998:22500,42996:22500,34768:22500,101747:30000,34769:22500,111442:170000,111454:170000,111441:170000,86069:300000,21217:1260,34764:22500,34766:22500,62659:67500,111436:170000,62662:96000,111453:170000,62665:96000,62666:96000,111446:170000,62657:67500,111449:170000,62652:67500,74656:300000,120293:170000,111434:170000,101750:30000,111433:170000,62669:96000,74643:200000,86073:300000,42999:22500,62668:96000,62661:96000,111439:170000,62653:67500,111444:170000,81406:200000,105721:300000,89594:67500,74647:300000,101617:30000,89596:2000,118416:170000,74646:300000,74648:300000,111438:170000,89601:67500,94535:300000,62670:96000,74653:300000,62656:67500,90457:200000,111431:170000,101748:30000,34762:22500,101616:30000,74654:200000,98127:300000,74652:300000,21072:567,62654:67500,46691:298800,34767:22500,45279:22500,89589:2000,86074:300000")
PT:AddData("MMM.Consumable.Food.Basic.Conjured","8076:3216,118050:170000,8075:2082,86508:200000,1114:825,22895:4320,118051:170000,22019:7500,5349:94,1113:365,1487:1215")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Conjured.Mana","70924:120000,70925:120000,118268:170000,118270:170000,118269:170000,118272:170000,118271:170000,70927:120000,70926:120000")

function MMMunch:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("MMMunchDB", defaults)
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MMMunch", options, nil)

    -- initialize flags
    self.inCombat = nil
    self.defaultMacroBody = "#showtooltip\n/use <hpp>"
    self.selectedMacro = nil
    self.selectedMacroName = ""
    self.selectedMacroBody = ""
    self.delayedMacroUpdate = false
    self.tagString = "\n#MMM"

    -- Register events
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerLeaveCombat")
    self:RegisterBucketEvent("BAG_UPDATE", 0.5, "OnBagUpdate")
    self:RegisterBucketEvent("UNIT_AURA", 0.5, "OnUnitAuraChanged")

    self.db.RegisterCallback(self, "OnNewProfile", "InitializePresets")
    self.db.RegisterCallback(self, "OnProfileReset", "InitializePresets")
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")

    -- Create Interface Config Options
    local ACD = LibStub("AceConfigDialog-3.0")
    ACD:AddToBlizOptions("MMMunch", "MuchMoreMunch", nil, "general")
    ACD:AddToBlizOptions("MMMunch", "Buff Preferences", "MuchMoreMunch", "buffPreferences")
    ACD:AddToBlizOptions("MMMunch", "User Added Items", "MuchMoreMunch", "userAddedItems")
    ACD:AddToBlizOptions("MMMunch", L["Profile"], "MuchMoreMunch", "profile")

    self:RegisterChatCommand("mmm", function() InterfaceOptionsFrame_OpenToCategory("MuchMoreMunch") end)
    self:RegisterChatCommand("muchmoremunch", function() InterfaceOptionsFrame_OpenToCategory("MuchMoreMunch") end)

    -- Populate lists
    self:RefreshCustomPTLists()
    self:UpdateItemList()
    self:UpdateMacroList()
end

function MMMunch:OnEnable()
    -- Called when the addon is enabled
end

function MMMunch:OnDisable()
    -- Called when the addon is disabled
end

function MMMunch:OnPlayerLogin()
    -- this space for rent
end

function MMMunch:OnPlayerEnterCombat()
    self.inCombat = true
end

function MMMunch:OnPlayerLeaveCombat()
    self.inCombat = false
    if self.delayedMacroUpdate == true then
        self:UpdateAll()
        self.delayedMacroUpdate = false
    end
end

function MMMunch:OnBagUpdate()
    if not self.inCombat then
        self:UpdateAll()
    else
        self.delayedMacroUpdate = true
    end
end

function MMMunch:OnUnitAuraChanged(...)
    local args = ...
    local unitID = args[1]

    if not unitID == "player" then return end

    if not self.inCombat then
        self:UpdateAll()
    else
        self.delayedMacroUpdate = true
    end
end

function MMMunch:ItemIdFromLink(itemLink)
    if itemLink == nil then return nil end

    local found, _, itemString = string.find(itemLink, "|H(.+)|h")
    if found then
        local _, itemId = strsplit(":", itemString)
        return tonumber(itemId)
    end
    return nil
end

function MMMunch:UpdatePercentageBasedItems()
    local maxHealth = UnitHealthMax("player")
    local maxPower = UnitPowerMax("player", "mana")
    local playerLevel = UnitLevel("player")
    local mana = math.floor(maxPower*0.15)

    -- Winter veil cookies
    -- From wowpedia
    local hpByLevel = {
        {90, 298,800},
        {85, 99,600},
        {80, 17,928},
        {70, 8,766},
        {60, 4,380},
        {50, 3,343},
        {40, 2,292},
        {30, 1,263},
        {20, 894},
        {10, 348},
    }
    --[[
        Stats (Y)
        86 - 90 = 108
        81 - 85 = 27
        80 =
        70 =
        60 =
        50 =
        40 = 5
        20 = 5
        10 = 4
    --]]
    local subValue = 0
    for i, v in ipairs(hpByLevel) do
        if v[1] <= playerLevel then
            subValue = v[2]
            break
        end
    end

    -- Override current fixed value with scaling value
    local ptString = ""
    ptString = PT:GetSetString("MMM.Consumable.Food.Buff.Combo.Non-Conjured")
    ptString = string.gsub(ptString, "21254:%d+", "21254:" .. subValue) -- Winter Veil Cookie
    ptString = string.gsub(ptString, "46691:%d+", "46691:" .. subValue) -- Bread of the Dead
    PT:AddData("MMM.Consumable.Food.Buff.Combo.Non-Conjured", ptString)

    ptString = PT:GetSetString("MMM.Consumable.Food.Buff.Combo.Non-Conjured.Mana")
    ptString = string.gsub(ptString, "21254:%d+", "21254:" .. subValue) -- Winter Veil Cookie
    ptString = string.gsub(ptString, "46691:%d+", "46691:" .. subValue) -- Bread of the Dead
    PT:AddData("MMM.Consumable.Food.Buff.Combo.Non-Conjured.Mana", ptString)

    subValue = math.floor(maxHealth*0.2)
    ptString = PT:GetSetString("Consumable.Warlock.Healthstone")
    ptString = string.gsub(ptString, "5512:%d+", "5512:" .. subValue) -- basic healthstone
    PT:AddData("Consumable.Warlock.Healthstone", ptString)

    subValue = math.floor(maxPower*0.15)
    ptString = PT:GetSetString("Consumable.Cooldown.Stone.Mana.Mana Stone")
    ptString = string.gsub(ptString, "36799:%d+", "36799:" .. subValue) -- basic mana gem
    ptString = string.gsub(ptString, "81901:%d+", "81901:" .. subValue) -- glyphed mana gem
    PT:AddData("Consumable.Cooldown.Stone.Mana.Mana Stone", ptString)
end

function MMMunch:CreateSubTable(itemList)
    local subTable = {}

    for _, item in pairs(itemList) do
        for itemType, _ in pairs(item.setValues) do
            local bestItem = nil
            local bestItemID = subTable[itemType]
            if bestItemID then bestItem = itemList[bestItemID] end

            bestItemID = self:FindBestItem(item, bestItem, itemType)

            if bestItemID ~= nil then subTable[itemType] = bestItemID end
        end
    end

    return subTable
end

function MMMunch:FindBestItem(item, best, itemType)
    if best == nil then
        best = item
    else
        local itemValue = item.setValues[itemType]
        local bestValue = best.setValues[itemType]

        -- Short Circuits
        if itemValue > bestValue then
            return item.itemID
        end

        if itemValue < bestValue then
            return best.itemID
        end

        -- Everything that gets here is same as best
        -- Check other priorities
        -- 1. Item is conjured
        -- 2. Item is not buff food
        -- 3. Item is not combo
        -- 4. Item has lower stackcount

        if item.weight > best.weight then
            return item.itemID
        elseif item.weight < best.weight then
            return best.itemID
        else
            if item.buffWeight > best.buffWeight then
                return item.itemID
            elseif item.buffWeight < best.buffWeight then
                return best.itemID
            else
                if item.count < best.count then
                    return item.itemID
                else
                    return best.itemID
                end
            end
        end
    end

    return best.itemID
end

local function NeedsBuff(item)
    local wellFed = UnitBuff("player", "Well Fed")

    if wellFed or not MMMunch.db.profile.maintainWellFed then
        return false
    end

    if item.isBuff and not wellFed then
        return true
    end

    return false
end

local PriorityList = {
    NeedsBuff,
    function(item) return item.isConjured end,
    function(item) return not item.isCombo end,
    function(item) return not item.isBuff end,
}

function MMMunch:GetWeight(item)
    local sum = 0

    for i, func in ipairs(PriorityList) do
        local weight = math.pow(10, #PriorityList - i)
        local x = func(item) and 1 or 0
        sum = sum + x * weight
    end

    return sum
end

function MMMunch:GetBuffWeight(item)
    local sum = 0
    local priorityList = self.db.profile.buffPriority

    for i, buffType in ipairs(priorityList) do
        local weight = math.pow(10, #priorityList - i)
        local x = item.buffs[buffType] or 0
        sum = sum + x * weight
    end

    return sum
end

function MMMunch:BagScan()
    local itemList = {}
    local playerLevel = UnitLevel("player")

    for bagID = 0, NUM_BAG_SLOTS do
        for slotID = 1, GetContainerNumSlots(bagID) do
            local itemID = self:ItemIdFromLink(GetContainerItemLink(bagID, slotID))
            -- skip this step if empty or item already found
            if itemID and not(itemList[itemID]) then
                local itemLevel = select(5, GetItemInfo(itemID))
                if itemLevel and (playerLevel >= itemLevel) then
                    for placeholder, categories in pairs(PLACEHOLDER_CATEGORIES) do
                        for _, set in ipairs(categories) do
                            -- check if the item belongs to this set
                            local value = PT:ItemInSet(itemID, set)

                            -- if it does, add it to the table of items for this set
                            if value then
                                local count = GetItemCount(itemID)
                                local item = itemList[itemID]

                                if item == nil then
                                    -- create the item object
                                    item = {
                                        name = GetItemInfo(itemID),
                                        itemID = itemID,
                                        setValues = {[placeholder] = tonumber(value)},
                                        count = count,
                                        isConjured = self:IsConjuredCategory(set),
                                        isCombo = self:IsComboCategory(set),
                                        isBuff = self:IsBuffCategory(set),
                                        buffs = {},
                                    }

                                    for buffType, _ in pairs(buffList) do
                                        local bvalue = PT:ItemInSet(itemID, "Consumable.Food.Buff." .. buffType)
                                        if bvalue then
                                            item.buffs[buffType] = tonumber(bvalue)
                                            --print(item.name ..": " .. buffType .. " = " .. tonumber(bvalue))
                                        end
                                    end

                                    item.weight = self:GetWeight(item)
                                    --print(item.name .. ": " .. item.weight)
                                    item.buffWeight = self:GetBuffWeight(item)
                                    --print(item.name .. ": " .. item.buffWeight)

                                    itemList[itemID] = item
                                else
                                    -- add this set and its value to the item object
                                    item.setValues[placeholder] = tonumber(value)
                                    item.isConjured = item.isConjured or self:IsConjuredCategory(set)
                                    item.isCombo = item.isCombo or self:IsComboCategory(set)
                                    item.isBuff = item.isBuff or self:IsBuffCategory(set)
                                    item.weight = self:GetWeight(item)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return itemList
end

function MMMunch:UpdateAll()
    self:UpdatePercentageBasedItems()

    local itemList = self:BagScan()
    self.subTable = self:CreateSubTable(itemList)
    self:UpdateBlizzMacros()
    self:UpdateDisplayedMacro()
end

function MMMunch:IsConjuredCategory(category)
    if string.find(category, "Conjured") and not (string.find(category, "Non%-Conjured")) then
        return true
    end
    return false
end

function MMMunch:IsComboCategory(category)
    if string.find(category, "Combo") then return true end

    return false
end

function MMMunch:IsBuffCategory(category)
    if string.find(category, "Buff") then return true end

    return false
end

-- Config dialog UI
function MMMunch:GetNewMacro(info)
    return ""
end

function MMMunch:SetNewMacro(info, name)
    if strtrim(name) == "" then return end

    local body = self.defaultMacroBody
    self.db.profile.macroTable[name] = body
    self:UpdateMacroList()

    self.selectedMacroName = name
    self:UpdateDisplayedMacro()
end

function MMMunch:UpdateDisplayedMacro()
    name = self.selectedMacroName
    self.selectedMacro = self:GetMacroListKeyByName(name)
    if self.selectedMacro then
        self.selectedMacroBody = self.db.profile.macroTable[name]
        options.args.general.args.macroName.disabled = false
        options.args.general.args.macroEditBox.disabled = false
        options.args.general.args.previewBody.name = self:ProcessMacro(self.selectedMacroBody)
        options.args.general.args.createMacro.disabled = false
    else
        self.selectedMacroName = nil
        self.selectedMacroBody = nil
        options.args.general.args.macroName.disabled = true
        options.args.general.args.macroEditBox.disabled = true
        options.args.general.args.previewBody.name = '\n\n\n\n\n'
        options.args.general.args.createMacro.disabled = true
    end
end

function MMMunch:GetSelectMacro(info)
    return self.selectedMacro
end

function MMMunch:SetSelectMacro(info, key)
    -- Update contents of macro edit box
    local name = options.args.general.args.macroSelectBox.values[key]
    self.selectedMacroName = name
    self:UpdateDisplayedMacro()
end

function MMMunch:GetMacroName(info)
    return self.selectedMacroName
end

function MMMunch:SetMacroName(info, name)
    if strtrim(name) == "" then return end

    -- Grabs the macro text stored under the old name and stores it under the new name
    local body = self.db.profile.macroTable[self.selectedMacroName]
    self.db.profile.macroTable[name] = body

    -- Erases the old name and sets the new name as the selection
    self.db.profile.macroTable[self.selectedMacroName] = nil
    self.selectedMacroName = name
    self:UpdateMacroList()
    self:UpdateDisplayedMacro()
end

function MMMunch:GetMacroBody(info)
    return self.selectedMacroBody
end

function MMMunch:SetMacroBody(info, body)
    self.db.profile.macroTable[self.selectedMacroName] = body
    self.selectedMacroBody = body
    self:UpdateDisplayedMacro()
    if not self.inCombat then
        self:GenerateMacro(self.selectedMacroName, body, false)
    else
        self.delayedMacroUpdate = true
    end
end

function MMMunch:UpdateMacroList()
    local macroList = {}
    for name, body in pairs(self.db.profile.macroTable) do
        table.insert(macroList, name)
    end

    table.sort(macroList)
    options.args.general.args.macroSelectBox.values = macroList
    options.args.general.args.macroDeleteBox.values = macroList
end

function MMMunch:GetMacroListKeyByName(name)
    local index = nil

    for i, macroName in ipairs(options.args.general.args.macroSelectBox.values) do
        if macroName == name then
            index = i
            break
        end
    end

    return index
end

function MMMunch:GetBuff1(info)
    return self.db.profile.buffPriority[1]
end

function MMMunch:SetBuff1(info, key)
    self.db.profile.buffPriority[1] = options.args.buffPreferences.args.buffSelectBox1.values[key]
    self:UpdateAll()
end

function MMMunch:GetBuff2(info)
    return self.db.profile.buffPriority[2]
end

function MMMunch:SetBuff2(info, key)
    self.db.profile.buffPriority[2] = options.args.buffPreferences.args.buffSelectBox2.values[key]
    self:UpdateAll()
end

function MMMunch:GetBuff3(info)
    return self.db.profile.buffPriority[3]
end

function MMMunch:SetBuff3(info, key)
    self.db.profile.buffPriority[3] = options.args.buffPreferences.args.buffSelectBox3.values[key]
    self:UpdateAll()
end


function MMMunch:GetMaintainWellFed(info)
    return self.db.profile.maintainWellFed
end

function MMMunch:SetMaintainWellFed(info, key)
    self.db.profile.maintainWellFed = not self.db.profile.maintainWellFed
    self:UpdateAll()
end

function MMMunch:GetAddItemType(info)
    return self.addItemType or "None"
end

function MMMunch:SetAddItemType(info, key)
    self.addItemType = options.args.userAddedItems.args.itemTypeSelectBox.values[key]
    self:UpdateAll()
end

function MMMunch:GetConjuredItem(info)
    if self.itemIsConjured == nil then
        return false
    end

    return self.itemIsConjured
end

function MMMunch:SetConjuredItem(info, key)
    self.itemIsConjured = not self.itemIsConjured
    self:UpdateAll()
end

function MMMunch:GetItemId(info)
    if self.addItemId == nil then
        return ""
    end

    return self.addItemId
end

function MMMunch:SetItemId(info, key)
    self.addItemId = strtrim(key)
    self:UpdateAll()
end

function MMMunch:GetItemValue(info)
    if self.addItemValue == nil then
        return ""
    end

    return self.addItemValue
end

function MMMunch:SetItemValue(info, key)
    self.addItemValue = strtrim(key)
    self:UpdateAll()
end

local itemCategoryLookup = {
    ["Health Potion"] = "mmmExtraHealthPots",
    ["Health Stone"] = "mmmExtraHealthStone",
    ["Mana Potion"] = "mmmExtraManaPots",
    ["Mana Stone"] = "mmmExtraManaStone",
    ["Health Food"] = "mmmExtraFoods",
    ["Mana Food"] = "mmmExtraDrinks",
    ["Bandage"] = "mmmExtraBandages",
}

function MMMunch:RefreshCustomPTLists()
    for category, _ in pairs(itemCategoryLookup) do
        local myStringNonConjured = ""
        local myStringConjured = ""
        local myString
        local ptListName = "MMMunch." .. itemCategoryLookup[category]

        for k, v in pairs(self.db.profile[category]) do
            if v[2] then
                myString = myStringConjured
            else
                myString = myStringNonConjured
            end

            if #myString > 0 then
                myString = myString .. ", "
            end
            myString = myString .. tostring(k) .. ":" .. tostring(v[1])

            if v[2] then
                myStringConjured = myString
            else
                myStringNonConjured = myString
            end
        end


        --self:Print(ptListName .. ":" .. myStringNonConjured)
        --self:Print(ptListName .. ".Conjured:" .. myStringConjured)

        PT:AddData(ptListName, myStringNonConjured)
        PT:AddData(ptListName .. ".Conjured", myStringConjured)

    end
end

function MMMunch:CreateItem()
    if self.addItemId == nil or self.addItemValue == nil or self.addItemType == nil then
        return false
    end

    local itemName = GetItemInfo(self.addItemId)

    self.db.profile.itemList[self.addItemId] = {
        itemID = self.addItemId,
        name = itemName,
    }
    self.db.profile[self.addItemType][self.addItemId] = {self.addItemValue, self.itemIsConjured}

    self:RefreshCustomPTLists()

    self:UpdateItemList()
    return true
end

function MMMunch:GetItemDelete(info)
    return nil
end

function MMMunch:SetItemDelete(info, key)
    local name = options.args.userAddedItems.args.itemDeleteBox.values[key]
    local _, itemLink = GetItemInfo(name)
    local itemId

    if itemLink then
        itemId = tostring(self:ItemIdFromLink(itemLink))
    end

    if itemId then
        self.db.profile.itemList[itemId] = nil

        -- Remember to delete from each of the sub-tables as well
        for k, _ in pairs(itemCategoryLookup) do
            self.db.profile[k][itemId] = nil
        end

        self:UpdateItemList()
    end
end

function MMMunch:UpdateItemList()
    local itemList = {}
    for k, v in pairs(self.db.profile.itemList) do
        table.insert(itemList, v.name)
    end

    table.sort(itemList)
    options.args.userAddedItems.args.itemDeleteBox.values = itemList
end

-- Macro Processing
function MMMunch:ProcessMacro(body)
    return self:SubPlaceHolders(body, self.subTable)
end

local PLACEHOLDER_PATTERN = "<([%l,%s]+)>"

function MMMunch:SubPlaceHolders(template, subTable)
    local subFunc = self:SubPatternFunc(subTable)
    local subCount = 0
    for chunk in string.gmatch(template, PLACEHOLDER_PATTERN) do
        local sub = subFunc(chunk)
        if sub ~= "" then subCount = subCount + 1 end
    end
    if subCount > 0 then
        return string.gsub(template, PLACEHOLDER_PATTERN, subFunc)
    else
        return nil
    end
end

function MMMunch:SubPatternFunc(subTable)
    return function (chunk)
        local bits = {strsplit(",", chunk)}
        local subbedString = ""
        for i, bit in ipairs(bits) do
            local itemID = subTable[strtrim(bit)]
            if itemID then
                if #subbedString > 0 then
                    subbedString = subbedString .. ", "
                end
                subbedString = subbedString .. "item:".. itemID
            end
        end

        return subbedString
    end
end

function MMMunch:CreateMacro()
    local name = self.selectedMacroName
    local body = self.selectedMacroBody
    local macroID = nil
    if not self.inCombat then
        macroID = self:GenerateMacro(name, body, true)
    end

    if macroID > 0 then
        PickupMacro(macroID)
    end
end

function MMMunch:GenerateMacro(name, body, create, macroID)
    if not macroID then macroID = GetMacroIndexByName(name) end

    local newBody = self:ProcessMacro(body)
    local warning = "/script DEFAULT_CHAT_FRAME:AddMessage(\"You have no suitable items.\")"

    if macroID == 0 and create then
        if newBody == nil then
            newBody = warning
        end
        macroID = CreateMacro(name, "INV_MISC_QUESTIONMARK", newBody .. self.tagString, nil, 1)

    elseif macroID > 0 then
        local macroBody = GetMacroBody(macroID)

        if newBody == nil then
            return 0
        end

        if string.find(tostring(macroBody), self.tagString) then
            macroID = EditMacro(macroID, name, "INV_MISC_QUESTIONMARK", newBody .. self.tagString, 1, nil)
        else
            macroID = 0
            self:Print(L["Blizzard macro update aborted: An unrecognised macro called %s already exists. Please rename your macro."](name))
        end
    end

    return macroID
end

function MMMunch:GetMacroDelete(info)
    return nil
end

function MMMunch:SetMacroDelete(info, key)
    local name = options.args.general.args.macroDeleteBox.values[key]
    self.db.profile.macroTable[name] = nil

    self:UpdateMacroList()
    self:UpdateDisplayedMacro()

    -- Do not add deletion of the blizzard macro!
    -- The action bar is tied to the macroID which changes when the macro is re-created
end

-- Process actual macros in Blizz macro interface
function MMMunch:UpdateBlizzMacros()
    local globalMacroCount, _ = GetNumMacros()

    for macroID = 1, globalMacroCount do
        local name, _, _, _ = GetMacroInfo(macroID)
        local body = self.db.profile.macroTable[name]
        if not (body == nil) then
            -- we've found a match and we want to update it
            self:GenerateMacro(name, body, false, macroID)
        end
    end
end



-- Profile Handling
function MMMunch:InitializePresets(db, profile)
    for k,v in pairs(PRESET_MACROS) do
        self.db.profile.macroTable[k] = v
    end
    self:RefreshConfig()
end

function MMMunch:RefreshConfig()
    self:UpdateMacroList()
    if not self.inCombat then
        self:UpdateBlizzMacros()
    else
        self.delayedMacroUpdate = true
    end
    self:UpdateDisplayedMacro()
end
