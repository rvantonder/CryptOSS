type user =
  | Org of string (* aggregate over a gh org's repos *)
  | SingleRepo of (string * string) (* reference a single repo *)
  | Invalid of string (* Invalid, with a reason *)

let cryptos =
  [
    "Bitcoin",
    None,
    Org "bitcoin"

  ; "Ripple",
    None,
    Org "ripple"

  ; "Ethereum",
    None,
    Org "ethereum"

  ; "Bitcoin Cash",
    None,
    Org "bitcoincashorg"

  ; "Cardano",
    None,
    Org "input-output-hk"

  ; "NEM",
    None,
    Org "NemProject"

  ; "Litecoin",
    None,
    Org "litecoin-project"

  ; "Stellar",
    None,
    Org "stellar"

  ; "TRON",
    None,
    Org "tronprotocol"

  ; "IOTA",
    None,
    Org "iotaledger"

  ; "Dash",
    None,
    Org "dashpay"

  ; "EOS",
    None,
    Org "eosio"

  ; "Monero",
    None,
    Org "monero-project"

  ; "NEO",
    None,
    Org "neo-project"

  ; "Qtum",
    None,
    Org "qtumproject"

  ; "Bitcoin Gold",
    None,
    Org "BTCGPU"

  ; "Ethereum Classic",
    None,
    Org "ethereumproject"

  ; "ICON",
    None,
    Org "theloopkr"

  ; "Lisk",
    None,
    Org "LiskHQ"

  ; "RaiBlocks",
    None,
    SingleRepo ("clemahieu", "raiblocks")

  ; "Siacoin",
    None,
    Org "NebulousLabs"

  ; "Bytecoin",
    None,
    SingleRepo ("amjuarez", "bytecoin")

  ; "Zcash",
    None,
    Org "zcash"

  ; "Verge",
    None,
    Org "vergecurrency"

  ; "OmiseGO",
    None,
    Org "omisego"

  ; "Dentacoin",
    None,
    Org "Dentacoin"

  ; "BitConnect",
    None,
    SingleRepo ("bitconnectcoin", "bitconnectcoin")

  ; "BitShares",
    None,
    Org "bitshares"

  ; "Populous",
    None,
    Org "bitpopulous"

  ; "Dogecoin",
    None,
    Org "dogecoin"

  ; "Binance Coin",
    None,
    Org "binance-exchange"

  ; "Stratis",
    None,
    Org "stratisproject"

  ; "Status",
    None,
    Org "status-im"

  ; "Ardor",
    None,
    Invalid "Bitbucket not supported"

  ; "Steem",
    None,
    Org "steemit"

  ; "Waves",
    None,
    Org "wavesplatform"

  ; "VeChain",
    None,
    Org "vechain"

  ; "KuCoin Shares",
    None,
    Invalid "Nothing"

  ; "Tether",
    None,
    Invalid ""

  ; "Cobinhood",
    None,
    Org "cobinhood"

  ; "Emercoin",
    None,
    Org "emercoin"

  ; "SmartCash",
    None,
    Org "SmartCash"

  ; "Ark",
    None,
    Org "ArkEcoSystem"

  ; "Loopring",
    None,
    Org "loopring"

  ; "GameCredits",
    None,
    Invalid "Nothing"

  ; "Nebulas",
    None,
    Org "nebulasio"

  ; "Bancor",
    None,
    Org "bancorprotocol"

  ; "MediBloc",
    None,
    Org "Medibloc"

  ; "Neblio",
    None,
    Org "NeblioTeam"

  ; "Particl",
    None,
    Org "Particl"

  ; "DigiByte",
    None,
    Org "digibyte"

  ; "Komodo",
    None,
    Org "SuperNETorg"

  ; "Dragonchain",
    None,
    Org "dragonchain"

  ; "Hshare",
    None,
    Org "Hcashorg"

  ; "Kin",
    None,
    Org "kinfoundation"

  ; "Electroneum",
    None,
    Org "electroneum"

  ; "Golem",
    None,
    Org "golemfactory"

  ; "Augur",
    None,
    Org "AugurProject"

  ; "Veritaseum",
    None,
    Org "veritaseum"

  ; "Ethos",
    None,
    Invalid "Nothing"

  ; "Basic Attention Token",
    None,
    Org "brave-intl"

  ; "Experience Points",
    None,
    SingleRepo ("eXperiencePoints", "XPCoin")

  ; "ReddCoin",
    None,
    Org "reddcoin-project"

  ; "FunFair",
    None,
    Invalid "Business model not open source"

  ; "Decred",
    None,
    Org "decred"

  ; "Kyber Network",
    None,
    Org "kybernetwork"

  ; "SALT",
    None,
    Invalid "Nothing"

  ; "Dent",
    None,
    Invalid "Nothing"

  ; "PIVX",
    None,
    Org "PIVX-Project"

  ; "QASH",
    None,
    Invalid "Nothing"

  ; "0x",
    None,
    Org "0xProject"

  ; "Nexus",
    None,
    Org "Nexusoft"

  ; "Aeternity",
    None,
    Org "aeternity"

  ; "Factom",
    None,
    Org "FactomProject"

  ; "aelf",
    None,
    Org "aelfProject"

  ; "Power Ledger",
    None,
    Invalid "Nothing"

  ; "Request Network",
    None,
    Org "RequestNetwork"

  ; "Aion",
    None,
    Org "aion-blockchain"

  ; "Substratum",
    None,
    Org "substratum-net"

  ; "WAX",
    None,
    Org "waxio"

  ; "Bytom",
    None,
    Org "Bytom"

  ; "DigitalNote",
    None,
    Org "xdn-project"

  ; "RChain",
    None,
    Org "rchain"

  ; "Nxt",
    None,
    Invalid "Bitbucket not supported"

  ; "MaidSafeCoin",
    None,
    Org "maidsafe"

  ; "Quantstamp",
    None,
    Org "quantstamp"

  ; "ChainLink",
    None,
    Invalid "nothing"

  ; "Gas",
    None,
    Invalid "nothing"

  ; "MonaCoin",
    None,
    SingleRepo ("monacoinproject", "monacoin")

  ; "Byteball Bytes",
    None,
    Org "byteball"

  ; "Santiment Network Token",
    None,
    Org "santiment"

  ; "BitcoinDark",
    None,
    SingleRepo ("jl777", "btcd")

  ; "Iconomi",
    None,
    Invalid "nothing"

  ; "Syscoin",
    None,
    Org "syscoin"

  ; "Enigma",
    None,
    Org "enigmampc"

  ; "ZCoin",
    None,
    Org "zcoinofficial"

  ; "BLOCKv",
    None,
    Org "BLOCKvIO"

  ; "PACcoin",
    None,
    Org "PaccoinCommunity"

  ; "Po.et",
    None,
    Org "poetapp"

  ; "Walton",
    None,
    Invalid "Nothing"

  ; "TenX",
    None,
    Org "tenx-tech"

  ; "DigixDAO",
    None,
    Org "digixglobal"

  ; "ETHLend",
    None,
    Org "ETHLend"

  ; "DeepBrain Chain",
    None,
    Invalid "Nothing"

  ; "Gnosis",
    None,
    Org "gnosis"

  ; "Civic",
    None,
    Invalid "No open source"

  ; "ZClassic",
    None,
    Org "z-classic"

  ; "Raiden Network Token",
    None,
    Org "raiden-network"

  ; "GXShares",
    None,
    Org "GXChain"

  ; "Maker",
    None,
    Invalid "Nothing"

  ; "Cindicator",
    None,
    Invalid "Nothing"

  ; "Bitcore",
    None,
    Org "LIMXTEC"

  ; "XPlay",
    None,
    Invalid ""

  ; "Cryptonex",
    None,
    Org "Cryptonex"

  ; "VIBE",
    None,
    SingleRepo ("amack2u", "VibeHub")

  ; "Storj",
    None,
    Org "Storj"

  ; "DEW",
    None,
    Invalid ""

  ; "SophiaTX",
    None,
    Invalid ""

  ; "Skycoin",
    None,
    Org "skycoin"

  ; "Time New Bank",
    None,
    SingleRepo ("fanxiong", "crowdsale-contracts")

  ; "iExec RLC",
    None,
    Org "iExecBlockchainComputing"

  ; "BridgeCoin",
    None,
    Invalid ""

  ; "Pillar",
    None,
    SingleRepo ("twentythirty", "PillarToken")

  ; "PayPie",
    None,
    Invalid ""

  ; "Achain",
    None,
    Org "Achain-Dev"

  ; "Vertcoin",
    None,
    Org "vertcoin"

  ; "NAV Coin",
    None,
    Org "NAVCoin"

  ; "High Performance Blockchain",
    None,
    Invalid ""

  ; "Enjin Coin",
    None,
    Org "enjin"

  ; "Dynamic Trading Rights",
    None,
    Invalid ""

  ; "Blocknet",
    None,
    Org "BlocknetDX"

  ; "Bibox Token",
    None,
    SingleRepo ("bibox365", "bixtoken")

  ; "Storm",
    None,
    SingleRepo ("StormX-Inc", "crowdsale")

  ; "XTRABYTES",
    None,
    SingleRepo ("borzalom", "XtraBYtes")

  ; "INS Ecosystem",
    None,
    Org "ins-ecosystem"

  ; "SuperNET",
    None,
    Org "SuperNETorg"

  ; "Ubiq",
    None,
    Org "ubiq"

  ; "Simple Token",
    None,
    Org "OpenSTFoundation"

  ; "SIRIN LABS Token",
    None,
    Org "sirin-labs"

  ; "AirSwap",
    None,
    Invalid ""

  ; "Edgeless",
    None,
    SingleRepo ("EdgelessCasino", "Smart-Contracts")

  ;  "Monaco",
     None,
     Invalid ""

  ; "AppCoins",
    None,
    Invalid ""

  ; "Telcoin",
    None,
    Org "telcoin"

  ; "Ripio Credit Network",
    None,
    Org "ripio"

  ; "SingularDTV",
    None,
    Invalid ""

  ; "Revain",
    None,
    Org "Revain"

  ; "Decentraland",
    None,
    Org "decentraland"

  ; "Counterparty",
    None,
    Org "CounterpartyXCP"

  ; "Einsteinium",
    None,
    SingleRepo ("emc2foundation", "einsteinium")

  ; "Red Pulse",
    None,
    Invalid ""

  ; "HTMLCOIN",
    None,
    Org "HTMLCOIN"

  ; "Peercoin",
    None,
    Org "peercoin"

  ; "BitBay",
    None,
    Invalid ""

  ; "Aragon",
    None,
    Invalid ""

  ; "WaBi",
    None,
    Invalid ""

  ; "IoT Chain",
    None,
    Org "IoTChainCode"

  ; "Quantum Resistant Ledger",
    None,
    Org "theQRL"

  ; "AdEx",
    None,
    Org "AdExBlockchain"

  ; "Ambrosus",
    None,
    Org "ambrosus"

  ; "Centra",
    None,
    Org "CentraTech"

  ; "ATMChain",
    None,
    Invalid ""

  ; "SONM",
    None,
    Org "sonm-io"

  ; "ZenCash",
    None,
    Org "ZencashOfficial"

  ; "SpankChain",
    None,
    Org "spankchain"

  ; "CyberMiles",
    None,
    Org "cybermiles"

  ; "Nuls",
    None,
    Org "nuls-io"

  ; "UTRUST",
    None,
    Invalid ""

  ; "Streamr DATAcoin",
    None,
    Org "streamr-dev"

  ; "Melon",
    None,
    Org "melonproject"

  ; "Gulden",
    None,
    Invalid ""

  ; "LBRY Credits",
    None,
    Org "lbryio"

  ; "Modum",
    None,
    Invalid ""

  ; "Unikoin Gold",
    None,
    Org "unikoingold"

  ; "QLINK",
    None,
    Org "qlinkdev"

  ; "Etherparty",
    None,
    Org "etherparty"

  ; "Triggers",
    None,
    Invalid ""

  ; "CoinDash",
    None,
    Invalid ""

  ; "Viacoin",
    None,
    Org "viacoin"

  ; "district0x",
    None,
    Org "district0x"

  ; "I/O Coin",
    Some "I.O Coin", (* view.ml has a replace "/" with "." for html index path. not ideal at all. But can't include path in crypto becuase thats gonna fuck up all data collected so far *)
    Org "IOCoin"

  ; "Wagerr",
    None,
    Org "wagerr"

  ; "Oyster",
    None,
    Org "oysterprotocol"

  ; "Wings",
    None,
    Invalid ""

  ; "Electra",
    None,
    Org "Electra-project"

  ; "Internet Node Token",
    None,
    Org "intfoundation"

  ; "Agoras Tokens",
    None,
    SingleRepo ("naturalog", "tauchain")

  ; "MobileGo",
    None,
    Invalid ""

  ; "Metal",
    None,
    Invalid ""

  ; "NAGA",
    None,
    Invalid ""

  ; "Rise",
    None,
    Org "risevision"

  ; "Bread",
    None,
    Invalid ""

  ; "Tierion",
    None,
    Org "tierion"

  ; "Burst",
    None,
    Org "PoC-Consortium"

  ; "Decision Token",
    None,
    Org "HorizonState"

  ; "Metaverse ETP",
    None,
    Org "mvs-org"

  ; "Lamden",
    None,
    Org "Lamden"

  ; "HempCoin",
    None,
    Org "hempcoin-project"

  ; "Hive",
    None,
    Invalid ""

  ; "Eidoo",
    None,
    Invalid ""

  ; "FirstBlood",
    None,
    Invalid ""

  ; "HelloGold",
    None,
    Invalid ""

  ; "CloakCoin",
    None,
    Org "CloakProject"

  ; "Asch",
    None,
    Org "AschPlatform"

  ; "Gifto",
    None,
    Org "GIFTO-io"

  ; "Aeon",
    None,
    Org "aeonix"

  ; "Lunyr",
    None,
    Org "Lunyr"

  ; "DECENT",
    None,
    Invalid ""

  ; "Grid+",
    None,
    Org "gridplus"

  ; "MediShares",
    None,
    Org "MediShares"

  ; "Agrello",
    None,
    Org "Agrello"

  ; "Mooncoin",
    None,
    Org "mooncoincore"

  ; "Voxels",
    None,
    Invalid ""

  ; "Groestlcoin",
    None,
    Org "Groestlcoin"

  ; "Flash",
    None,
    Org "flashcoin-io"

  ; "Genesis Vision",
    None,
    Org "GenesisVision"

  ; "MinexCoin",
    None,
    Org "minexcoin"

  ; "BitClave",
    None,
    Org "bitclave"

  ; "Cofound.it",
    None,
    Invalid ""

  ; "Everex",
    None,
    Invalid ""

  ; "WeTrust",
    None,
    Org "WeTrustPlatform"

  ; "iXledger",
    None,
    Invalid ""

  ; "COSS",
    None,
    Invalid ""

  ; "Worldcore",
    None,
    Invalid ""

  ; "Monetha",
    None,
    Org "monetha"

  ; "Namecoin",
    None,
    Org "namecoin"

  ; "Shift",
    None,
    Org "ShiftNrg"

  ; "Lykke",
    None,
    Org "LykkeCity"

  ; "Pura",
    None,
    Org "PURAcore"

  ; "Mercury",
    None,
    Org "SigwoTechnologies"

  ; "SaluS",
    None,
    Org "saluscoin"

  ; "Feathercoin",
    None,
    Org "FeatherCoin"

  ; "TaaS",
    None,
    Invalid ""

  ; "Trade Token",
    None,
    Invalid ""

  ; "Dimecoin",
    None,
    SingleRepo ("peme0815","dimecoin")

  ; "ECC",
    None,
    Invalid ""

  ; "adToken",
    None,
    Invalid ""

  ; "Safe Exchange Coin",
    None,
    Invalid ""

  ; "YOYOW",
    None,
    Invalid ""

  ; "Datum",
    None,
    Invalid ""

  ; "Ink",
    None,
    Org "inklabsfoundation"

  ; "Crown",
    None,
    Org "Crowndev"

  ; "Jinn",
    None,
    Invalid ""

  ; "Spectrecoin",
    None,
    Org "spectrecoin"

  ; "SHIELD",
    None,
    Org "ShieldCoin"

  ; "Viberate",
    None,
    Invalid ""

  ; "Voise",
    None,
    Invalid ""

  ; "Paypex",
    None,
    Invalid ""

  ; "Elastic",
    None,
    SingleRepo ("sprocket-fpga", "xel_miner")

  ; "TokenCard",
    None,
    Invalid ""

  ; "Delphy",
    None,
    Org "DelphyProject"

  ; "Presearch",
    None,
    Org "presearchofficial"

  ; "Pascal Coin",
    None,
    Org "PascalCoin"

  ; "Pepe Cash",
    None,
    Invalid ""

  ; "LAToken",
    None,
    SingleRepo ("ElKornacio", "contracts-early")

  ; "Matchpool",
    None,
    Org "Matchpool"

  ; "Bloom",
    None,
    Org "hellobloom"

  ; "VeriCoin",
    None,
    Org "vericoin"

  ; "Mothership",
    None,
    Invalid ""

  ; "PotCoin",
    None,
    Org "potcoin"

  ; "Diamond",
    None,
    Org "DMDcoin"

  ; "Humaniq",
    None,
    Org "humaniq"

  ; "Neumark",
    None,
    Org "Neufund"

  ; "BlockMason Credit Protocol",
    None,
    Invalid ""

  ; "Snovio",
    None,
    Invalid ""

  ; "Blocktix",
    None,
    Org "blocktix"

  ; "SunContract",
    None,
    Org "SunContract"

  ; "Synereo",
    None,
    Org "synereo"

  ; "SIBCoin",
    None,
    SingleRepo ("ivansib", "sibcoin")

  ; "ION",
    None,
    Org "ionomy"

  ; "SolarCoin",
    None,
    SingleRepo ("onsightit", "solarcoin")

  ; "EncrypGen",
    None,
    Invalid ""

  ; "bitCNY",
    None,
    Invalid ""

  ; "WhiteCoin",
    None,
    Invalid ""

  ; "Game.com",
    None,
    Org "GameLeLe"

  ; "FairCoin",
    None,
    Org "FairCoinTeam"

  ; "DeepOnion",
    None,
    Org "deeponion"

  ; "BlackCoin",
    None,
    Invalid ""

  ; "Expanse",
    None,
    Org "expanse-org"

  ; "Bounty0x",
    None,
    Org "bounty0x"

  ; "Rivetz",
    None,
    Invalid ""

  ; "Numeraire",
    None,
    Org "numerai"

  ; "Moeda Loyalty Points",
    None,
    Org "moedabank"

  ; "NVO",
    None,
    Org "nvoproject"

  ; "DomRaider",
    None,
    Invalid ""

  ; "Zeusshield",
    None,
    Invalid ""

  ; "Divi",
    None,
    Org "Divicoin"

  ; "NuShares",
    None,
    Invalid "bitbucket"

  ; "GridCoin",
    None,
    Org "gridcoin"

  ; "NewYorkCoin",
    None,
    Org "NewYorkCoin-NYC"

  ; "Nimiq",
    None,
    Org "nimiq-network"

  ; "Ormeus Coin",
    None,
    Invalid ""

  ; "Peerplays",
    None,
    Org "PBSA"

  ; "Maecenas",
    None,
    Invalid ""

  ; "Propy",
    None,
    Invalid ""

  ; "Dovu",
    None,
    Invalid "No, that open source link is someone else's smart contracts"

  ; "Myriad",
    None,
    Org "myriadteam"

  ; "NoLimitCoin",
    None,
    Org "NoLimitCoin"

  ; "AirToken",
    None,
    Invalid ""

  ; "Bodhi",
    None,
    Org "bodhiproject"

  ; "Greencoin",
    None,
    Org "greencoin-dev"

  ; "Steem Dollars",
    None,
    Org "steemit" (* this is like, unfair *)

  ; "Stox",
    None,
    Org "stx-technologies"

  ; "Aeron",
    None,
    Org "aeronaero"

  ; "Aurora DAO",
    None,
    Invalid ""

  ; "Xenon",
    None,
    Invalid ""

  ; "Phore",
    None,
    Org "phoreproject"

  ; "Golos",
    None,
    Org "GolosChain"

  ; "OKCash",
    None,
    Org "okcashpro"

  ; "MonetaryUnit",
    None,
    Org "MUEcoin"

  ; "Radium",
    None,
    Org "RadiumCore"

  ; "Omni",
    None,
    Org "OmniLayer"

  ; "NeosCoin",
    None,
    Invalid ""

  ; "ALIS",
    None,
    Org "AlisProject"

  ; "Bean Cash",
    None,
    Org "TeamBitBean"

  ; "OAX",
    None,
    Invalid "GitLab"

  ; "Pandacoin",
    None,
    Org "DigitalPandacoin"

  ; "ATBCoin",
    None,
    Invalid ""

  ; "Blackmoon",
    None,
    Org "blackmoonfg"

  ; "Rubycoin",
    None,
    Org "rubycoinorg"

  ; "Target Coin",
    None,
    Invalid ""

  ; "DubaiCoin",
    None,
    Org "dubaicoin-dbix"

  ; "Linda",
    None,
    Org "Lindacoin"

  ; "LIFE",
    None,
    Invalid ""

  ; "InvestFeed",
    None,
    Invalid ""

  ; "Bismuth",
    None,
    SingleRepo ("hclivess", "Bismuth")

  ; "Nexium",
    None,
    Invalid ""

  ; "DecentBet",
    None,
    Invalid ""

  ; "Neutron",
    None,
    Org "neutroncoin"

  ; "Credo",
    None,
    Invalid ""

  ; "LEOcoin",
    None,
    Org "Leocoin-project"

  ; "Playkey",
    None,
    Org "Playkey"

  ; "PoSW Coin",
    None,
    Invalid ""

  ; "Hush",
    None,
    Org "MyHush"

  ; "eBitcoin",
    None,
    Org "eBTCCommunityTrustToken"

  ; "Open Trading Network",
    None,
    Org "OpenTradingNetworkFoundation"

  ; "Mintcoin",
    None,
    Org "MintcoinCommunity"

  ; "QunQun",
    None,
    Invalid ""

  ; "Ignis",
    None,
    Invalid "" 

(*
Incent
None


FlorinCoin
KickCoin
BLUE
Paragon
Publica
Swarm City
Patientory
Databits
Bitcrystals
Chronobank
CVCoin
MyBit Token
Hedge
Rialto
LoMoCoin
Oxycoin
Aigang
OracleChain
Energycoin
Unobtanium
Xaurum
BlockCAT
Soarcoin
Waves Community Token
FoldingCoin
AsiaCoin
Espers
LUXCoin
Polis
Obsidian
Polybius
ColossusCoinXT
Elixir
Circuits of Value
LockChain
GoByte
Clams
*)

  ]
