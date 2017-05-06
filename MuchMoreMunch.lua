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
PT:AddData("MMM.Consumable.Food.Combo.Conjured.Mana","34062:10650,43518:100%,43523:100%,65499:100%,65500:100%,65515:100%,65516:100%,65517:100%,80610:100%,80618:30000,113509:100%")
PT:AddData("MMM.Consumable.Food.Basic.Conjured.Mana","2136:1253,2288:907,3772:2160,5350:324,8077:3510,8078:5580,8079:9720,22018:10230,30703:7248")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Conjured.Mana","70924:29400,70925:29400,70926:29400,70927:29400,118268:170000,118269:170000,118270:170000,118271:170000,118272:170000")
PT:AddData("MMM.Consumable.Food.Buff.Basic.Non-Conjured","724:453,1017:844,1082:844,2680:302,2683:453,2684:453,2687:453,2888:302,3220:453,3662:453,3663:844,3664:844,3665:844,3666:844,3726:844,3727:844,3728:1458,3729:1458,4457:1458,5472:302,5474:302,5476:453,5477:453,5479:844,5480:844,5525:453,5527:844,6038:1458,6888:302,7806:302,7807:302,7808:302,11584:302,12209:844,12210:1458,12212:1458,12213:1458,12214:1458,12215:2904,12216:2904,12218:2904,12224:302,13851:1458,13929:1458,16971:2904,17197:302,17198:129,17222:2904,18045:2904,20074:1458,20452:5244,21023:8832,21254:24402,22645:453,23756:302,24105:302,24539:8832,27635:302,27636:453,27651:8832,27655:8832,27657:10650,27658:10650,27659:10650,27660:10650,27662:8832,27663:8832,27664:10650,27665:10650,27666:10650,27667:10650,29292:5244,30155:8832,30357:10650,30358:10650,30359:10650,30361:10650,31672:10650,31673:10650,32721:8520,33052:10650,33867:8832,33872:10650,34125:21252,34748:21252,34749:21252,34750:21252,34751:21252,34752:21252,34754:21252,34755:21252,34756:21252,34757:21252,34758:21252,35563:4044,39691:21252,42779:17454,42994:21252,42995:21252,42997:21252,43001:21252,46392:844,57519:302,64641:1458,77264:111,77272:111,77273:111,81400:20000,81401:20000,81402:20000,81403:30000,81404:20000,81405:20000,81408:30000,81409:30000,81410:30000,81411:30000,81412:30000,81413:30000,88379:20000,98121:30000,98122:30000,98123:30000,98124:30000,98125:30000,98126:30000,104339:30000,104340:30000,104341:30000,104342:30000,104343:30000,104344:30000,105717:30000,105719:30000,105720:30000,105722:30000,105723:30000,105724:30000,140338:453,140342:10650")
PT:AddData("MMM.Consumable.Food.Combo.Non-Conjured.Mana","2682:529,3448:529,13724:4884,19301:15660,20031:10308,28112:15660,32722:6132,33053:10650,34759:21252,34760:21252,34761:21252,34780:10650,43478:21252,43480:21252,45932:42504,68687:16536,75026:20000,75038:30000,86026:20000,87253:30000,98111:20000,98116:20000,98118:20000,104196:20000,108920:30000,111544:170000,112449:30000,118424:170000,130259:170000,133575:1200000,138983:1200000,138986:1200000,139398:1200000,140355:1200000")
PT:AddData("MMM.Consumable.Food.Basic.Non-Conjured","117:162,414:453,422:844,733:844,787:162,961:162,1326:453,1707:2500,2070:162,2287:453,2679:162,2681:162,2685:844,3770:844,3771:2500,3927:2904,4536:162,4537:453,4538:844,4539:2500,4540:162,4541:453,4542:844,4544:2500,4592:453,4593:844,4594:2500,4599:2904,4601:2904,4602:2904,4604:162,4605:453,4606:844,4607:2500,4608:2904,4656:162,5057:162,5066:453,5095:453,5478:844,5526:844,6290:162,6299:147,6316:453,6807:2500,6887:2904,6890:453,7097:162,7228:844,8364:2500,8932:5244,8948:5244,8950:5244,8952:5244,8953:5244,8957:5244,9681:2904,11109:147,11415:5244,11444:5244,11951:3174,12238:453,13546:2904,13755:2500,13810:6237,13893:2904,13927:1879,13928:1879,13930:2904,13931:2116,13932:2116,13933:5244,13934:10212,13935:5244,16166:162,16167:453,16168:2904,16169:2500,16170:844,16171:5244,16766:2904,17119:453,17344:162,17406:453,17407:2500,17408:2904,18254:4719,18255:2904,18632:2500,18633:453,18635:2904,19223:162,19224:2500,19225:5244,19304:453,19305:844,19306:2904,20857:162,21030:2904,21031:5244,21033:5244,21552:2904,22324:5244,23160:4494,23495:162,24008:10212,24009:10212,24072:453,24338:5244,27661:15336,27854:15336,27855:15336,27856:15336,27857:15336,27858:15336,27859:15336,28486:15336,28501:10212,29393:15336,29394:10650,29412:15336,29448:10650,29449:10650,29450:10650,29451:10650,29452:10650,29453:10650,30355:10650,30458:15336,30610:15336,30816:162,32685:10650,32686:10650,33048:10650,33443:17454,33449:17454,33451:17454,33452:17454,33454:17454,34747:21252,35565:4044,35947:21252,35948:21252,35949:17454,35950:21252,35951:21252,35952:21252,35953:21252,37252:17454,37452:17454,38427:15336,38428:10650,38706:21252,40202:21252,40356:17454,40358:17454,40359:17454,41729:21252,41751:15336,42428:17454,42429:21252,42430:17454,42431:21252,42432:17454,42433:17454,42434:21252,42778:21252,43087:21252,44049:21252,44071:21252,44072:21252,44607:21252,44608:17454,44609:17454,44722:21252,44749:17454,44854:162,44855:162,44940:21252,45901:21252,46690:162,46784:162,46793:162,46796:162,46797:162,49253:162,49361:453,49397:453,49600:453,49603:453,57518:844,57544:162,58258:16536,58259:23520,58260:16536,58261:23520,58262:16536,58263:23520,58264:16536,58265:23520,58266:16536,58267:23520,58268:16536,58269:23520,58275:21252,58276:21252,58277:21252,58278:21252,58279:21252,58280:21252,59227:21252,59228:16536,59231:21252,59232:16536,60267:162,60268:162,60375:162,60377:162,60378:162,60379:162,61383:2500,62676:16536,62677:23520,62909:453,62910:844,63691:2904,63692:2500,63693:844,63694:844,65730:844,65731:844,67230:453,67270:5244,67271:5244,67272:5244,67273:5244,67361:162,67362:162,67363:162,67364:162,67365:162,67366:162,67367:162,67368:162,67369:162,67370:162,67371:162,67372:162,67373:162,67374:162,67375:162,67376:162,67377:162,67378:162,67379:162,67380:162,67381:162,67382:162,67383:162,67384:162,69243:17454,69244:2904,69920:453,73260:23520,74609:21252,74641:30000,74921:23520,81175:20000,81889:20000,81916:30000,81917:20000,81918:30000,81919:20000,81920:30000,81921:30000,81922:20000,82448:20000,82449:30000,82450:20000,82451:30000,83097:20000,85504:20000,86057:20000,88398:30000,90135:30000,105708:30000,111456:170000,111842:25000,112095:453,113099:170000,113290:170000,115351:170000,115352:170000,115353:170000,115354:170000,115355:170000,116120:221000,117454:170000,117457:170000,117469:170000,117470:170000,117471:170000,117472:170000,117473:170000,117474:170000,128219:170000,128498:170000,128761:170000,128763:700000,128764:1200000,128835:1200000,128836:700000,128837:700000,128838:1200000,128839:700000,128840:1200000,128843:700000,128844:1200000,128845:700000,128846:1200000,128847:1200000,128848:700000,128849:700000,128851:1200000,130192:221000,132752:1200000,132753:1200000,133893:1200000,133979:1200000,133981:1200000,135557:1200000,136544:1200000,136545:1200000,136546:1200000,136547:1200000,136548:1200000,136549:1200000,136550:1200000,136551:1200000,136552:1200000,136553:1200000,136554:1200000,136555:1200000,136556:700000,136557:1200000,136558:1200000,136559:1200000,136560:1200000,138285:700000,138290:1200000,138291:1200000,138972:1200000,138973:1200000,138974:1200000,138976:700000,138977:700000,138978:1200000,138979:700000,138980:700000,138987:700000,139344:700000,139345:1200000,140184:1200000,140201:700000,140202:700000,140205:1200000,140206:1200000,140207:1200000,140273:1200000,140275:1200000,140276:700000,140286:1200000,140296:1200000,140297:1200000,140299:1200000,140300:1200000,140301:1200000,140302:1200000,140337:162,140339:5244,140341:21252,140344:15336,140626:700000,140627:1200000,140631:1200000,140668:700000,140679:1200000,140753:844,140754:844,141206:1200000,141207:1200000,141208:1200000,141212:1200000,141213:1200000,141214:1200000")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Non-Conjured.Mana","21072:546,21217:1423,33004:8802,34753:21252,34762:21252,34763:21252,34764:21252,34765:21252,34766:21252,34767:21252,34768:21252,34769:21252,42942:21252,42993:21252,42996:21252,42998:21252,42999:21252,43000:21252,43015:21252,43268:21252,44953:21252,45279:21252,60858:16536,62649:23520,62651:16536,62652:16536,62653:16536,62654:16536,62655:16536,62656:16536,62657:16536,62658:16536,62659:16536,62660:16536,62661:23520,62662:23520,62663:23520,62664:23520,62665:23520,62666:23520,62667:23520,62668:23520,62669:23520,62670:23520,62671:23520,74642:20000,74643:20000,74644:20000,74645:30000,74646:30000,74647:30000,74648:30000,74649:30000,74650:30000,74651:20000,74652:30000,74653:30000,74654:20000,74655:30000,74656:30000,79320:36000,81406:20000,81414:30000,86069:30000,86070:30000,86073:30000,86074:30000,88388:30000,88586:30000,89588:30000,89589:26088,89590:27276,89591:44316,89592:25572,89593:17944,89594:16536,89595:30000,89596:26088,89597:27276,89598:44316,89599:25572,89600:17944,89601:16536,90457:20000,94535:30000,98127:30000,101616:30000,101617:30000,101618:30000,101630:30000,101661:30000,101662:30000,101727:30000,101729:30000,101740:30000,101745:30000,101746:30000,101747:30000,101748:30000,101749:30000,101750:30000,105721:30000,111431:170000,111432:170000,111433:170000,111434:170000,111435:170000,111436:170000,111437:170000,111438:170000,111439:170000,111440:170000,111441:170000,111442:170000,111443:170000,111444:170000,111445:170000,111446:170000,111447:170000,111448:170000,111449:170000,111450:170000,111451:170000,111452:170000,111453:170000,111454:170000,118416:170000,118428:170000,120293:170000,122343:170000,122344:170000,122345:170000,122346:170000,122347:170000,122348:170000,129179:1200000,133557:1200000,133561:1200000,133562:1200000,133563:1200000,133564:1200000,133565:1200000,133566:1200000,133567:1200000,133568:1200000,133569:1200000,133570:1200000,133571:1200000,133572:1200000,133573:1200000,133574:1200000,133576:1200000,133577:1200000,140343:30000")
PT:AddData("MMM.Consumable.Food.Combo.Non-Conjured","2682:529,3448:529,13724:4884,19301:15660,20031:10308,28112:15660,32722:6132,33053:10650,34759:21252,34760:21252,34761:21252,34780:10650,43478:21252,43480:21252,45932:42504,68687:16536,75026:20000,75038:30000,86026:20000,87253:30000,98111:20000,98116:20000,98118:20000,104196:20000,108920:30000,111544:170000,112449:30000,118424:170000,130259:170000,133575:1200000,138983:1200000,138986:1200000,139398:1200000,140355:1200000")
PT:AddData("MMM.Consumable.Food.Basic.Non-Conjured.Mana","159:324,1179:907,1205:1253,1401:216,1645:3510,1708:2160,4791:2160,8766:5580,9451:1253,10841:2160,17404:907,18300:9720,19299:1253,19300:3510,27860:10230,28399:7248,29395:10230,29401:10230,29454:7248,30457:10230,32453:10230,32455:9720,32668:10230,33042:10230,33444:12126,33445:4704,33825:10230,34411:10230,35954:10230,37253:10230,38429:5580,38430:7248,38431:10230,38698:12126,39520:18138,40357:10230,41731:4704,42777:4704,43086:12126,43236:4704,44750:10230,44941:12126,49254:324,49365:907,49398:907,49601:907,49602:907,58256:11028,58257:23520,58274:4704,59029:11028,59229:4704,59230:11028,60269:324,61382:2160,62672:23520,62675:23520,63023:3510,63251:23520,63530:907,68140:23520,74636:30000,74822:23520,75037:15000,81923:30000,81924:20000,85501:20000,88532:30000,88578:30000,90659:907,90660:1253,104348:30000,105700:30000,105701:30000,105702:30000,105703:30000,105704:30000,105705:30000,105706:30000,105707:30000,105711:30000,111455:170000,117452:170000,117475:170000,120168:170000,128385:170000,128850:1200000,128853:700000,133586:700000,138292:1200000,138975:700000,138982:1200000,139346:700000,139347:1200000,140203:700000,140204:1200000,140265:1200000,140266:1200000,140269:1200000,140272:1200000,140298:1200000,140340:20000,140628:700000,140629:1200000,141215:1200000,141527:700000")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Conjured","70924:29400,70925:29400,70926:29400,70927:29400,118268:170000,118269:170000,118270:170000,118271:170000,118272:170000")
PT:AddData("MMM.Consumable.Food.Basic.Conjured","1113:453,1114:844,1487:2500,5349:162,8075:2904,8076:5244,22019:10650,22895:8832,86508:20000,118050:170000,118051:170000")
PT:AddData("MMM.Consumable.Food.Combo.Conjured","34062:10650,43518:100%,43523:100%,65499:100%,65500:100%,65515:100%,65516:100%,65517:100%,80610:100%,80618:30000,113509:100%")
PT:AddData("MMM.Consumable.Food.Buff.Combo.Non-Conjured","21072:546,21217:1423,33004:8802,34753:21252,34762:21252,34763:21252,34764:21252,34765:21252,34766:21252,34767:21252,34768:21252,34769:21252,42942:21252,42993:21252,42996:21252,42998:21252,42999:21252,43000:21252,43015:21252,43268:21252,44953:21252,45279:21252,60858:16536,62649:23520,62651:16536,62652:16536,62653:16536,62654:16536,62655:16536,62656:16536,62657:16536,62658:16536,62659:16536,62660:16536,62661:23520,62662:23520,62663:23520,62664:23520,62665:23520,62666:23520,62667:23520,62668:23520,62669:23520,62670:23520,62671:23520,74642:20000,74643:20000,74644:20000,74645:30000,74646:30000,74647:30000,74648:30000,74649:30000,74650:30000,74651:20000,74652:30000,74653:30000,74654:20000,74655:30000,74656:30000,79320:36000,81406:20000,81414:30000,86069:30000,86070:30000,86073:30000,86074:30000,88388:30000,88586:30000,89588:30000,89589:26088,89590:27276,89591:44316,89592:25572,89593:17944,89594:16536,89595:30000,89596:26088,89597:27276,89598:44316,89599:25572,89600:17944,89601:16536,90457:20000,94535:30000,98127:30000,101616:30000,101617:30000,101618:30000,101630:30000,101661:30000,101662:30000,101727:30000,101729:30000,101740:30000,101745:30000,101746:30000,101747:30000,101748:30000,101749:30000,101750:30000,105721:30000,111431:170000,111432:170000,111433:170000,111434:170000,111435:170000,111436:170000,111437:170000,111438:170000,111439:170000,111440:170000,111441:170000,111442:170000,111443:170000,111444:170000,111445:170000,111446:170000,111447:170000,111448:170000,111449:170000,111450:170000,111451:170000,111452:170000,111453:170000,111454:170000,118416:170000,118428:170000,120293:170000,122343:170000,122344:170000,122345:170000,122346:170000,122347:170000,122348:170000,129179:1200000,133557:1200000,133561:1200000,133562:1200000,133563:1200000,133564:1200000,133565:1200000,133566:1200000,133567:1200000,133568:1200000,133569:1200000,133570:1200000,133571:1200000,133572:1200000,133573:1200000,133574:1200000,133576:1200000,133577:1200000,140343:30000")

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

local PERCENTAGE_ITEMS = {
    {43518, 100},
    {43523, 100},
    {65499, 100},
    {65500, 100},
    {65515, 100},
    {65516, 100},
    {65517, 100},
    {80610, 100},
    {113509, 100},
}

local HP_CATEGORIES = {
    "MMM.Consumable.Food.Basic.Non-Conjured",
    "MMM.Consumable.Food.Combo.Non-Conjured",
    "MMM.Consumable.Food.Basic.Conjured",
    "MMM.Consumable.Food.Combo.Conjured",
    "MMM.Consumable.Food.Buff.Basic.Non-Conjured",
    "MMM.Consumable.Food.Buff.Combo.Non-Conjured",
    "MMM.Consumable.Food.Buff.Combo.Conjured",
}

local MP_CATEGORIES = {
    "MMM.Consumable.Food.Basic.Non-Conjured.Mana",
    "MMM.Consumable.Food.Combo.Non-Conjured.Mana",
    "MMM.Consumable.Food.Basic.Conjured.Mana",
    "MMM.Consumable.Food.Combo.Conjured.Mana",
    --"MMM.Consumable.Food.Buff.Basic.Non-Conjured.Mana",
    "MMM.Consumable.Food.Buff.Combo.Non-Conjured.Mana",
    "MMM.Consumable.Food.Buff.Combo.Conjured.Mana",
}

function MMMunch:UpdatePercentageBasedItems()
    local maxHealth = UnitHealthMax("player")
    local maxPower = UnitPowerMax("player", SPELL_POWER_MANA)
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
    
    -- Iterate through the list of PERCENTAGE_ITEMS and replace the ptString as needed
    for _, percentItemId in ipairs(PERCENTAGE_ITEMS) do
        subValue = maxHealth * percentItemId[2]/100
        for _, hpCategory in ipairs(HP_CATEGORIES) do
            ptString = PT:GetSetString(hpCategory)
            ptString = string.gsub(ptString, percentItemId[1] .. ":%d+%%", percentItemId[1] .. ":" .. subValue) 
            PT:AddData(hpCategory, ptString)
        end
        
        subvalue = maxPower * percentItemId[2]/100
        for _, mpCategory in ipairs(MP_CATEGORIES) do
            ptString = PT:GetSetString(mpCategory)
            ptString = string.gsub(ptString, percentItemId[1] .. ":%d+%%", percentItemId[1] .. ":" .. subValue) 
            PT:AddData(mpCategory, ptString)
        end
    end
    
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
