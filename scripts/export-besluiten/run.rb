#!/usr/bin/env ruby

require 'bundler/inline'
require 'yaml'
require 'securerandom'
require 'date'
require 'rdf/vocab'
require 'rdf/turtle'
require 'rdf/reasoner'

$stdout.sync = true
ENV['LOG_SPARQL_ALL']='false'
ENV['MU_SPARQL_ENDPOINT']='http://virtuoso:8890/sparql'
ENV['MU_SPARQL_TIMEOUT']='180'
require 'mu/auth-sudo'

$gemeenteraad_org_uris = [
  "http://data.lblod.info/id/bestuursorganen/029cac3e-437e-4fb2-962b-36e3c650faf5",
  "http://data.lblod.info/id/bestuursorganen/0303a4354c9731170a209a4930b679dbef7e6fe98ece80a48112883141a031e0",
  "http://data.lblod.info/id/bestuursorganen/0430cc3f20c4720ada0e826919ca0fca5dcb21049e54a41978e54c9c71842251",
  "http://data.lblod.info/id/bestuursorganen/06b277d8ea03a625bbf37baf3f7b7033050ca49d43480a30fbfffed07b76dc47",
  "http://data.lblod.info/id/bestuursorganen/08f55558-6453-4c2c-acd6-bef1d9bb3ee0",
  "http://data.lblod.info/id/bestuursorganen/0bafeec206151798d9a811cf5b45991ac46cc3b3ee8c48dedd0813e8ab00c888",
  "http://data.lblod.info/id/bestuursorganen/0bcd626eb9ce2b2bb03f250297c233c0b69eaed411b1fcd5e41be3133bbdc3b5",
  "http://data.lblod.info/id/bestuursorganen/0f5288768dc2570fe856cab05dd65f0dce9e58b1db37df5496d29f63ad3d7f7e",
  "http://data.lblod.info/id/bestuursorganen/0f64dec39b3cc3d5439f75a601710ff502a7e62a905f6090c3f7b6474f2a8df7",
  "http://data.lblod.info/id/bestuursorganen/0fda7b61b413be91cdfa1e543a801ec8ca5903cb756d0f3040db6f8c7d4f4a5d",
  "http://data.lblod.info/id/bestuursorganen/1037789762c0a76baf305e48959efb72704280330a1d7630f6c00fa27e772ba9",
  "http://data.lblod.info/id/bestuursorganen/1250ce033a9b2c384badc83a107fa676f38c24cac5a3ebe2aabed3390ab7a376",
  "http://data.lblod.info/id/bestuursorganen/14b7303caceb9072a53043c6ba4c9fa940517ba0ca0ff883e179ad7ba2f99ebc",
  "http://data.lblod.info/id/bestuursorganen/1627055a1f920eb748fcd4e0986067fa7844ee5ceb42dc3789f6f4d5f4b7c610",
  "http://data.lblod.info/id/bestuursorganen/18b1f7a571b9b610ea350dc3f4ded9ef08d0d8b7e811b50ef5109297a5039c6b",
  "http://data.lblod.info/id/bestuursorganen/18f8ca614feaee634c4d86221b09fc551b07964661aec4eec8648768578b903a",
  "http://data.lblod.info/id/bestuursorganen/1b1cafa62202d8bde96df409dd8ca3a2af6cd736ceba53abe8d9479da592bce5",
  "http://data.lblod.info/id/bestuursorganen/1b33b026820e346192688540c81bf1429b82a57e878c3326cb6ea367c723d497",
  "http://data.lblod.info/id/bestuursorganen/1d4e16288d3b545be627972a9d1b2258c2e56c5288b11eedbd551659885bf8fb",
  "http://data.lblod.info/id/bestuursorganen/1d7bf361d1727f8df4f33c8ee9cfb3a6ca6e17cab29876bb99016c3e453ede46",
  "http://data.lblod.info/id/bestuursorganen/1e225e1ccf49f065896760af5f50f63f09852d2447da1bc8a87bd248231b299e",
  "http://data.lblod.info/id/bestuursorganen/1e9b7974430d18506fb0f04ed7da5da3996af2b4e9df3f6776f051bd53b4e9ae",
  "http://data.lblod.info/id/bestuursorganen/217dd0dca840ab0c7f39b550b19b83f426d99d978f5fdc2c4b8338ac85d3358d",
  "http://data.lblod.info/id/bestuursorganen/22701079f3c4fc214fb23779477ec35f6e544a19c9cb13b88fb8fa0b78db58c5",
  "http://data.lblod.info/id/bestuursorganen/239e4bf67c7ee631afba74072b550ac73a9829e47af7dbc5253cbedbd1f944f1",
  "http://data.lblod.info/id/bestuursorganen/239ed6c07341c2037248db5943141e0fe71e5a11993f4f3c98e7009d23cf3db7",
  "http://data.lblod.info/id/bestuursorganen/23b5a629cb4b53d4c3b5f878410559eed5364e4178e4f3702adef831a0cfffe0",
  "http://data.lblod.info/id/bestuursorganen/2503e52d18b6de5cd540e93670cdf267688a26028d314017045fddc9c601064e",
  "http://data.lblod.info/id/bestuursorganen/26afbc11cef8ebc11c15537bb9d3c35ae67886d8825074c2656af4fcb75ebf3b",
  "http://data.lblod.info/id/bestuursorganen/31cdfe166bd08ca77ef5b66d1e72107c94846def897f13d52c821668afe5d9c1",
  "http://data.lblod.info/id/bestuursorganen/321d1f9be9c759ee935d413949e2f357554d73cca8f9cccdf07d6779fb025639",
  "http://data.lblod.info/id/bestuursorganen/323648caf7feae2bde2275469f2b09dbcba52a9658bd0de159924e84998ba6f5",
  "http://data.lblod.info/id/bestuursorganen/329c7f6c6005aa94e6217bd001903111ccd5f68f0cc3a2b20fdd849a12da2331",
  "http://data.lblod.info/id/bestuursorganen/334c42860702b6f687ea3124be4e38c82e0ccf4c2109084b9b87db9600319d9a",
  "http://data.lblod.info/id/bestuursorganen/33b8f54bb39efce6aa208f2a14ebd65b8d7546edd130fabfc51d71edb81ae925",
  "http://data.lblod.info/id/bestuursorganen/341d2682102434354f04ee1437a3435ea4bb2bc0846b121dd454692d3dc7fe11",
  "http://data.lblod.info/id/bestuursorganen/37947496af7d48fe5fea5f2d3ffe55a90034bd44ce87ca8b11458747f1212b66",
  "http://data.lblod.info/id/bestuursorganen/379d50591d747de727cadf0d8a738492528d6ef778c75cb93a0c183a0fe0bf4a",
  "http://data.lblod.info/id/bestuursorganen/38fdabd0c7218d13904fc34d77298e30b28da7b1a0904107dd0d4ff67e3b0a9f",
  "http://data.lblod.info/id/bestuursorganen/391a09bae8808a58b96eecfecbdcbcb3ab470ce3374625d82395952bac1272cb",
  "http://data.lblod.info/id/bestuursorganen/3b74569c223cbe4a95932012e7858b1f85e07c3ee00632779dba2cb7cd8454ef",
  "http://data.lblod.info/id/bestuursorganen/3d2d73c89e832bfe2324631ce615908370750d185772f59a99ef4745befd1606",
  "http://data.lblod.info/id/bestuursorganen/3d9e2a2859b1a8f1ace9620dbc2b40ac29b10e62d84d41b4823a233eb5eaae3e",
  "http://data.lblod.info/id/bestuursorganen/40359d89f77bbb18336d75a1747e86433ad8eacc91d17bdfc4b7d22eb315540c",
  "http://data.lblod.info/id/bestuursorganen/41a698719ec2d45bb3bcae3d528a281dd45c305a26cd2292b1749ad819064382",
  "http://data.lblod.info/id/bestuursorganen/41e0fea8ad30c62ccce56945df7a289757f1c67b8fe1b7be8e1ec72e1e9cc48c",
  "http://data.lblod.info/id/bestuursorganen/436a64e8ff1d64ea7a7933c1543250ea56ab5853e3c8744936c896219dc6ed63",
  "http://data.lblod.info/id/bestuursorganen/43fd2810e2aa4de231db8848f25c453556be74cdf61e6055936ff837831d3ebd",
  "http://data.lblod.info/id/bestuursorganen/44d83f242a9e71b1411fd9f736e5fd1d56fcf86019fb26b88ad7e727ab48bdb9",
  "http://data.lblod.info/id/bestuursorganen/491e9f3ac4efc1e5eb27b308cd0f2f8ccd1e3a0d5147a0b6247dbe24648bcc6c",
  "http://data.lblod.info/id/bestuursorganen/4b7b530b97eedbebed35aebaf919b23d282d1112c587da96d4c1ee19d66045ad",
  "http://data.lblod.info/id/bestuursorganen/4bc6b373-dd44-4c30-ad5b-47f9a28f3b08",
  "http://data.lblod.info/id/bestuursorganen/4d4541a07717e84e183b13c4400212d9dd708c2c470b0854e5631ef278d8dbf7",
  "http://data.lblod.info/id/bestuursorganen/4d7bf0c06c7ccb777a71e5690c4c6385bd57b5924c7856f7ab8fdd144fdf4bba",
  "http://data.lblod.info/id/bestuursorganen/4dcd964bc1cf296f19e286eca41b65fcd25077618a12237ccda54f693f0c14c2",
  "http://data.lblod.info/id/bestuursorganen/4ef4cf7aa5f23cce4ed7f79e47c72c2196f7a972f4b44da835bc907591f7e5ef",
  "http://data.lblod.info/id/bestuursorganen/4f49f21da99f8a2e98bdaf17a287d76e9f4609906630fdfde4c46dc5d5db6c2b",
  "http://data.lblod.info/id/bestuursorganen/51662d4fdbf379b5e5fb531fd307b322c79f05d59076d8016b2283300e672449",
  "http://data.lblod.info/id/bestuursorganen/51de4479bd44f610b20c60aa43de50418b4dc35150c1afe40122673b18becc68",
  "http://data.lblod.info/id/bestuursorganen/522186bc20abef2d4273a2acce0d6e9113b2b79f35fe24ea373bd478639b66a2",
  "http://data.lblod.info/id/bestuursorganen/5241d9f7e4cfe54d3ffcadcd58ac929f080c18df607a84a1f98e37bee7601619",
  "http://data.lblod.info/id/bestuursorganen/54dd2c5e762102239fdd443ef63b4cab784c9b815c3a70ca79d5ca8ae7c150a0",
  "http://data.lblod.info/id/bestuursorganen/54f62c2852996f718e3cdb711baf0735365fec955e31e52e245b3fd21a78bf5a",
  "http://data.lblod.info/id/bestuursorganen/569d80ff4d16ce411d1b99e9d428dbabade0ef38606a371736ab39173b8295a2",
  "http://data.lblod.info/id/bestuursorganen/56e7dbac89d8386adacdece973cbab5dd2f0463eaf8b2090c6322974c8c979c9",
  "http://data.lblod.info/id/bestuursorganen/5720eafeeb2ac7bb31631763f9c7c4fe435a535c5ce8b7f189ff177c51cdfee6",
  "http://data.lblod.info/id/bestuursorganen/57a67d7da1818ed85af8d37e98f22aa69e751adfe1b74878282c15872c7baf7e",
  "http://data.lblod.info/id/bestuursorganen/5c2aca0923f110ee42e02f0858d995032d7509d1a5fa7ae2d03ca77bfab45ac5",
  "http://data.lblod.info/id/bestuursorganen/5c5e173fa4f8f05a79de5af183fd9619f04bf5c171e031c6b65e013b98329914",
  "http://data.lblod.info/id/bestuursorganen/5ccd265b9ccb979d53d701e5ec2c0d73a07029299a60b39b424d5e2e6d33c9e8",
  "http://data.lblod.info/id/bestuursorganen/5e760eb8cd7da832917768c4bc95db2e8a2a7417c94fbb5ef3adab9101ef14e3",
  "http://data.lblod.info/id/bestuursorganen/5fc839030966749c81ebc3336920e6dee3e97b9a8f57ccae8204b171054b6955",
  "http://data.lblod.info/id/bestuursorganen/65bb32c6572c96d4fbb7d0bdd3b2bd1e74192decd2a845c14d9bb08677ffed32",
  "http://data.lblod.info/id/bestuursorganen/67a39ba2ba12ae17291c8c0d09d2849fbe771b4fbdb6a7c7cf3198ab60c73bd8",
  "http://data.lblod.info/id/bestuursorganen/67f50bf01884bb80bb9d5ba9ffdc32f07e8fbe4058f5ec1c0f7ff1ebbc455cf0",
  "http://data.lblod.info/id/bestuursorganen/6e96282fb0e237354a2ae4a1d0bbdbb9b5777b15a4849663f73152c14f40814c",
  "http://data.lblod.info/id/bestuursorganen/73bf5f318f9dbc173214c6efa072cc812f042885efd8d86f7a9cd24abb8bfaf6",
  "http://data.lblod.info/id/bestuursorganen/773f6f8080ebe2394b2d465e5930f65d21511527bddaa589b97bd11a8010c7d2",
  "http://data.lblod.info/id/bestuursorganen/77cffa10518c50f5f0c647d22d131700b45c5c49af8ace686ae770972c02ef95",
  "http://data.lblod.info/id/bestuursorganen/79477d421718142babf486f3973c1f2de1c7a7eb04bef41e19fa36345eb2f903",
  "http://data.lblod.info/id/bestuursorganen/7d9be4014135ccfb9517c85f5930b001622bc17074bf581184d654c1f9e0c080",
  "http://data.lblod.info/id/bestuursorganen/7e50e4b289a4e7fee594e6458331af994e1536dab7a60ece3aa9de96164856a0",
  "http://data.lblod.info/id/bestuursorganen/7f2917c70fd989eab156248ffe1542b167abb96d310ba83d25e3bb3f87f752c8",
  "http://data.lblod.info/id/bestuursorganen/80262090b326c006cfc5e6140809a362260f1ca2445848eae46f3266b5f1cd4b",
  "http://data.lblod.info/id/bestuursorganen/822433205a41ef80005686050d7ab9e3a207cf07c0c1b3bbe5d879e7dcf363e9",
  "http://data.lblod.info/id/bestuursorganen/846adb296e9cfa17b3f17bbcac7611d2413502ccfcdfe7f8a8b6e70fd88ec3fc",
  "http://data.lblod.info/id/bestuursorganen/86c74df3458eb2f6de9587e0787e91917163ecdf316f2de9f9c416ef75becfc0",
  "http://data.lblod.info/id/bestuursorganen/86e676362d55396012f6cb6d9444ae9051d2a43100dd9fe12bfc85eb4598378f",
  "http://data.lblod.info/id/bestuursorganen/86f71269cf4aa079a22226c891b435be1e5ffb028cba88a735a9be4607955e53",
  "http://data.lblod.info/id/bestuursorganen/8a3b0d931e07317343c5417b8ff5998b854bca4b406fc9e54da00a6532f2f25b",
  "http://data.lblod.info/id/bestuursorganen/8bc7b7f63f97de59c4a888f73dc78a6f18a3865e69d0ae829846d7ae86a5117d",
  "http://data.lblod.info/id/bestuursorganen/8d8072a8de7040475ccee682dcc823a4bca4eccdd175433efec8be89488ec863",
  "http://data.lblod.info/id/bestuursorganen/8dfc47b866f15b6936d82a09a7c27ad3044b1533972ff7368f5124dead497da8",
  "http://data.lblod.info/id/bestuursorganen/8ef9bea3ed25b8543d1fb4aa387337704c1fd686d4ee46f2c7ddfa963460de3f",
  "http://data.lblod.info/id/bestuursorganen/914e741553bb16bc2d950eea77ba92257a8df4b49038d35810a2a7fd738ccc9d",
  "http://data.lblod.info/id/bestuursorganen/91f85dbe-4059-4c39-8a3a-ce9585a97283",
  "http://data.lblod.info/id/bestuursorganen/944634742d6dbce6c2502d8101474cf82b16da2cb6d16ee0d4edbb23e2f51c5b",
  "http://data.lblod.info/id/bestuursorganen/96d6978e82e87124e6582328ceaaa58a60f4902ecc9916781a8092a71c4ba572",
  "http://data.lblod.info/id/bestuursorganen/9877d55da079273a991a505e9af79aa8a564f40d864cedaba3306b4f3d51d40b",
  "http://data.lblod.info/id/bestuursorganen/9c337100-8c65-45de-8bef-919993501c5f",
  "http://data.lblod.info/id/bestuursorganen/9df2d27c713f17036617b7565c074f8f85664f19166300f59aa65f08ff8fedd1",
  "http://data.lblod.info/id/bestuursorganen/a2695acf7f9822a70ce8e03b7a620cbdc5260f84cb0e70501369d9df3d52a82f",
  "http://data.lblod.info/id/bestuursorganen/a3680ea983aad22f7e20751696cb7bbcca6acc717c88b9ab475babe44d1e9819",
  "http://data.lblod.info/id/bestuursorganen/a423b2ec-2162-4b06-9260-22ada39a90fd",
  "http://data.lblod.info/id/bestuursorganen/a7338ee700c1413b892676cae27f677d77afffcd908aea76eed107829e0efd81",
  "http://data.lblod.info/id/bestuursorganen/a7d5f33cf143c0202789ffe161e79405206ba6e0e2bfe74152d6bd9b5b110907",
  "http://data.lblod.info/id/bestuursorganen/ac113a2966ad48003b012e45445ccc0907452ee3b96cfdc962855e56c1b7fad4",
  "http://data.lblod.info/id/bestuursorganen/aee8fa5f2e9fc4b901503f2b1c90a5a986a78698f31d698af0b8286a4c2cc229",
  "http://data.lblod.info/id/bestuursorganen/b27b29dbe653c85edf8d9db60206a52fea80c0088aa721757ddbc5a6a1311821",
  "http://data.lblod.info/id/bestuursorganen/b3ad412c-9028-48c4-bf80-344ebe075463",
  "http://data.lblod.info/id/bestuursorganen/b508e9023d90b9a0ea7b9e2368ba347d54421c5be0c64c0df261360ad1015fd8",
  "http://data.lblod.info/id/bestuursorganen/b6a9eb9b14a837f9e2a2175a02ac7d2f1ae815f98268a4b141bcaf838cace29c",
  "http://data.lblod.info/id/bestuursorganen/b6ab845c5652e3a7e0a6ccd07134f36a7f1cc7585f809cd4cb541d43e6d81348",
  "http://data.lblod.info/id/bestuursorganen/b6c94184c0d62ec7a3b63696bb1ac6855b66c62e81b2ff371e0938bd42fdac17",
  "http://data.lblod.info/id/bestuursorganen/ba3afb178194c918df4bbf4ebe16ba13fb9d89d7c2d44810c4902a17cb4f148e",
  "http://data.lblod.info/id/bestuursorganen/bb027647fa3b1c06d004b09810708a2c62fbc37c69af6815e214f43fdf551132",
  "http://data.lblod.info/id/bestuursorganen/bc0148b89dc1c85e8c50e49f1b83da26113da0b6bdbc9314ae018a6a692387e0",
  "http://data.lblod.info/id/bestuursorganen/bcc66b0e14ac1b3e8ff2200dcac3b11b1f4ee1a8c76794d043fd5c8676c847c8",
  "http://data.lblod.info/id/bestuursorganen/c123d49030da89d8bedf86cdabbd8884feb4ffb85162cde052f2ba52afbc1739",
  "http://data.lblod.info/id/bestuursorganen/c126b20bc1a94de293b7fceaf998c82e9a7a1d56ba34cbf9992aa4bf01ae2b01",
  "http://data.lblod.info/id/bestuursorganen/c15657e33d38762d25b1b084322f53e6bad535fbaf2e431c91e92316cbe8ae79",
  "http://data.lblod.info/id/bestuursorganen/c3124fae2b9ca41f2c50f5090d8cf1c255b9bdbf473a8b3412e0197cce2a6927",
  "http://data.lblod.info/id/bestuursorganen/c383d01e15613617577a4eb19674a9901c43e6ac26e4045009f1e6548f289383",
  "http://data.lblod.info/id/bestuursorganen/c3cd9ddf39269aa1818cccea34cfde4729807793e742e1263e4ef039f666e9cc",
  "http://data.lblod.info/id/bestuursorganen/c533fbcd252dcd62381136909d705799cc688cedb0d4a4381e7aaa338a3af5c7",
  "http://data.lblod.info/id/bestuursorganen/c6c3ec0edbeb2471fed4f292e31cdbe9d3037b7c541c49d6a35007b8d2c48a40",
  "http://data.lblod.info/id/bestuursorganen/c7b7f21c440afce29c2e0203b37673127b9f95a253cc6c270aefb9c533da851b",
  "http://data.lblod.info/id/bestuursorganen/c80e06b8e0368c57b03edb888e96b6a38943d0736f725fa4a1bdecee75114a18",
  "http://data.lblod.info/id/bestuursorganen/c96762fe5afdd792fa8a75402aa5bd29b3852b901aa597e29248397f64babc5b",
  "http://data.lblod.info/id/bestuursorganen/caf7d8e02fc7faed0eebd5dc335451531d473c43f56c6561c8f58ee0f0a477ab",
  "http://data.lblod.info/id/bestuursorganen/cec81c059243f68785bab1427c0538d3dbb9eb2beb86b3a12a137ae61dea9241",
  "http://data.lblod.info/id/bestuursorganen/cfe526667734e4bc8f89eaa5e3e2c0c91ea707b6831d9a08bbcdc318d375f47c",
  "http://data.lblod.info/id/bestuursorganen/d0b72df2920b04201fd1b2fa2efa2312f9968a6d549ca16b55f0c9d1fd725d48",
  "http://data.lblod.info/id/bestuursorganen/d32cd863bf4ebfac8264fbbcd2a151e0e4bb48d9c02ab80be03489b466fcf28d",
  "http://data.lblod.info/id/bestuursorganen/d4c9cea3c2e31e0646604092474c38209613f43ca44a1a82b44d380dd0f4f4f9",
  "http://data.lblod.info/id/bestuursorganen/d587d50fd5e7245de0664aed846ed74e45d8d42b5be05619d9ae3a7daf55d2dc",
  "http://data.lblod.info/id/bestuursorganen/d61013793c6a085fad7f575eef3cec4df3cbb988cd2da83e3f1f10a0b4a9899d",
  "http://data.lblod.info/id/bestuursorganen/d9f8f122341d0a3d78f7eeed4c4d6eac169e85f644be76872ff66f750a22b023",
  "http://data.lblod.info/id/bestuursorganen/da61f995ce7aa6506879c9e7488b29f59e9651f52e30e2fff21f35ae073ea1c7",
  "http://data.lblod.info/id/bestuursorganen/dc6a50fa1cf2c4ede156e00fd07c5bb9294126b98bfc029553c8992d99189647",
  "http://data.lblod.info/id/bestuursorganen/ddc73bfa33434f2068be21f791ac6ce6bb261b0ddd65d4aed5e2fedc38cfceeb",
  "http://data.lblod.info/id/bestuursorganen/e1648f7819d5de86e7d3e9646c286438690070feeddb5e2951b8ac59d192eeed",
  "http://data.lblod.info/id/bestuursorganen/e19aca3abd8a4ae3dfaba82776c91838da8f4ea8c5c073b648f7a425922c46e7",
  "http://data.lblod.info/id/bestuursorganen/e280902f-347d-45f5-90ae-80dc141425b3",
  "http://data.lblod.info/id/bestuursorganen/e3d9480acc0cf400e11ab7afe2bcea144038dd2ef71d77247d5159c7ce8efb1a",
  "http://data.lblod.info/id/bestuursorganen/e4cf97522f4c478eb21064242276739ecfbf17183636a720c17c13dfdb256791",
  "http://data.lblod.info/id/bestuursorganen/e711777f70be44307d8a9b0b237ba9c22e4a7c9a55bd52440042892fd143ed4a",
  "http://data.lblod.info/id/bestuursorganen/e8baefcfa6bd6c43717e75c05ee90e3ae45d265c74fa36b84564edcb810f58bf",
  "http://data.lblod.info/id/bestuursorganen/e9e9065c49c1a32d4c543c9c18ddecc66ba5d4d03816c7d1d07fbe734d4456e8",
  "http://data.lblod.info/id/bestuursorganen/ec51645aca4dda2c477a77c952f19548c4ee2562b18b111d278772885770ec7e",
  "http://data.lblod.info/id/bestuursorganen/ed04026321d1ae83e687f621dd5b055f7eeaccb112a5c37d939c402e8f9ed9cf",
  "http://data.lblod.info/id/bestuursorganen/ee2da5d88b7ae59a0dcf8d3bf82ba8e11a4b9a7fd6e5f9e31a4a38d3ff431d45",
  "http://data.lblod.info/id/bestuursorganen/eee0f3433a2198d679168406cb8d35c137a1a91356d2e1c59c4408822ca3ec09",
  "http://data.lblod.info/id/bestuursorganen/f0e3cfed5293cff34e5d05e642ec78376b11343d36e58d33a10d47cf95684b7b",
  "http://data.lblod.info/id/bestuursorganen/f2dfb294b972c321f0b001dec8d353a195720736d2bb35bfc1f4db7182faaff3",
  "http://data.lblod.info/id/bestuursorganen/f36964e6c0cdf4ddbe0bf6357ae68a978c841f9bf7d57584b5b8011152d52f46",
  "http://data.lblod.info/id/bestuursorganen/f5d08b32a422fe73b6d3caac3bc7a1ed989da648cea624c0d3e7f0a9fa26d762",
  "http://data.lblod.info/id/bestuursorganen/f614b2838f95e8e14b055c4df46c89c31dbf71c063f11faec00c797e9eaae3be",
  "http://data.lblod.info/id/bestuursorganen/f69c67b2c49a7c19a67c7efeda542857f2ee482a2ea308b853e6c9df24246541",
  "http://data.lblod.info/id/bestuursorganen/f74ef257ee6dc8a84c982112baf6de506d5cb7660e92028a00461c7ed3564416",
  "http://data.lblod.info/id/bestuursorganen/f7d10f86f4cdccbb7e72fce0b199ba578e6d19180c4ad5d62b9f65c20095cfa5",
  "http://data.lblod.info/id/bestuursorganen/f7ddf4a92c4d266b6b569a6dc0f1ec8f5ec99abee00d0ec68b667200298f2fa4",
  "http://data.lblod.info/id/bestuursorganen/f90b7d9cb1f1f2be8cb084caa9c784b87a1732f1c2a156fba41c8ff36f8d28dc",
  "http://data.lblod.info/id/bestuursorganen/f9b2e25ad65f403f1fbe343aa02403bb2638e18cdd2a983abf17e133dfef19cf",
  "http://data.lblod.info/id/bestuursorganen/fa0f562ffb87c1346f1b9f9153e1694506a30ec9eaa7819212fbc04fa38fd8bd",
  "http://data.lblod.info/id/bestuursorganen/fa4341dcfc652d20fc772e93de39f556106365f8a79abf1102b0eab7fb24aa6b",
  "http://data.lblod.info/id/bestuursorganen/fdb8c286b212bfe30afe42f47c2057d9d10fa7e3eb4ecd86697fee5d691e2649",
  "http://data.lblod.info/id/bestuursorganen/ff6e64ed48d31534b55aabc43a6ad97ae42d624e20b73941d8bdbce6d3042550"
]

$rmw_org_uris = [
  "http://data.lblod.info/id/bestuursorganen/021e584167379392b4ee3ab54d0e4304aa37182c538b6949c426333d243f178c",
  "http://data.lblod.info/id/bestuursorganen/0283c1dea9635ed0caa7954a2b0e42440e24c6198215a671c5a6681d61cadd43",
  "http://data.lblod.info/id/bestuursorganen/031dcc0b2957c2be13617633d38e9b06794fc52781e66d435753e647ec16d871",
  "http://data.lblod.info/id/bestuursorganen/035f2f1b975344a4e6c0e46e336fb1449d214eb72b80af37b50516d9f1d7d9ba",
  "http://data.lblod.info/id/bestuursorganen/04e965b3f13cfe29e367d4d81033396c159f5c967e2ec59102d06d8fa89208bd",
  "http://data.lblod.info/id/bestuursorganen/05701e64d201c0268cca2e7e9df59707d7c7c259d94e7048ee05134ece122ee0",
  "http://data.lblod.info/id/bestuursorganen/064f54d79e7705e5fc4860f3b5d218dd87c1bed1032ea86f17ca8b369b5eb33f",
  "http://data.lblod.info/id/bestuursorganen/082976d57de0655ac4f123b57d5cb008f612956d0a6de1742c02913dcbfcf125",
  "http://data.lblod.info/id/bestuursorganen/0845f849a16ec00b9a22da409746fe9d69e6ca34e84df2eec4b831c8dfe4f98d",
  "http://data.lblod.info/id/bestuursorganen/093ca80d-1040-4551-bb98-b122b34b8593",
  "http://data.lblod.info/id/bestuursorganen/0d22465017b934c55b8392f11f9196ddf8fbdc9d9cc952dd874cec0cef2d6c6d",
  "http://data.lblod.info/id/bestuursorganen/0e4952dd6a8393ba568d77336d78d713f996ddf1fe63fea7bbf6a415367f1d94",
  "http://data.lblod.info/id/bestuursorganen/0ecda94e4ae4214451850a0c514335a09fc2807ea7f1fadf722c06eb8ed6ca49",
  "http://data.lblod.info/id/bestuursorganen/115fabbb14f811f7d14ff67ce44042fd3919568129060171f743efbf9ccf9919",
  "http://data.lblod.info/id/bestuursorganen/1189ca51e5c099e5e31d65ac813dfdbeff0103a4b6d76d85caf7b44b7fb452cc",
  "http://data.lblod.info/id/bestuursorganen/121b6f9cba84d8ea8f3c220ab6acf49b9cbbf9e2d4e75b4839f3d32c5e8f2c42",
  "http://data.lblod.info/id/bestuursorganen/140408d18b3383f3bd343bc8a6a7ccef45c41a8923a18a2e04a75a19a10531a9",
  "http://data.lblod.info/id/bestuursorganen/14ba858efc0657c7d401c7cc517c8a91fdbaec730b5f9b3cdb8da7b4b7f67c82",
  "http://data.lblod.info/id/bestuursorganen/1676258fbd4792e3e4617b4acbb2ae1cdebedeabca27971f515f3938c35808fc",
  "http://data.lblod.info/id/bestuursorganen/1ba0a9a8aa4772e98f8015fdf33d26880c193bc0862149060859b54f99f1e258",
  "http://data.lblod.info/id/bestuursorganen/1c3aa67a2b9654cebbbc9b2bf319269ba1f4243719400fdd7fcf37b3e7e3a450",
  "http://data.lblod.info/id/bestuursorganen/1d0d4f779fdad78704d7ed1c2ecee0377715b0e2780536640bc92f8c0c5902a0",
  "http://data.lblod.info/id/bestuursorganen/1d9a2fe32f7f8946f3decd01ec8ea35609610d9bd8c4619f7500d6529ca3a58b",
  "http://data.lblod.info/id/bestuursorganen/1dd8d07a2aead35d87c61d536f8e409119be8790f8c70a2709d6faa061c6c030",
  "http://data.lblod.info/id/bestuursorganen/1fc1e70ea537e823e78e4d7edf4e8236548cc62bf56bb7be947bb563fcb11c59",
  "http://data.lblod.info/id/bestuursorganen/1fc2419c030912c0637c01ef96a5ac07585328e5a3b7ffdd85675a0766a08756",
  "http://data.lblod.info/id/bestuursorganen/23e73f44-1fb9-4ca8-a936-04a8c83d707a",
  "http://data.lblod.info/id/bestuursorganen/252626e734bd14c0b673222c499bf10fdf10c0a7f8f337a09d1614adaac7ce2e",
  "http://data.lblod.info/id/bestuursorganen/25c79c8f75553362d484240991a34e31838927d495c7f0338b728a1c5404d368",
  "http://data.lblod.info/id/bestuursorganen/26a5bb59-2174-4cd0-a0f9-bfe97401e3b9",
  "http://data.lblod.info/id/bestuursorganen/2807abe173ca16753327969db7a02cbefa30f5342eb28a615056d629cf2d83c1",
  "http://data.lblod.info/id/bestuursorganen/29303bc16a48829cef3e64713f8809d0baf4f6c429494527d45128965bb79c71",
  "http://data.lblod.info/id/bestuursorganen/298f32bc45f96c6512842dd7f1cdadbfb5a30fed9b0a25449d4c7b337954df4c",
  "http://data.lblod.info/id/bestuursorganen/2b5f4204ac69e8a002b3561001ad311b9f00f981967613ba3dc42fc916cdcff1",
  "http://data.lblod.info/id/bestuursorganen/2c833738f6d77689433cb7d81f8583142ea826f6dd2000b6c243b7ea8f7537c5",
  "http://data.lblod.info/id/bestuursorganen/2d22df31ac1189ccd103fb8ae35a76fed560f27b2d193f3e7e3d76858df08aa6",
  "http://data.lblod.info/id/bestuursorganen/2d59ac0a62975b180f5a9691d9bab8bf234d25bb9be4a0f03d4d5bd462d56cf4",
  "http://data.lblod.info/id/bestuursorganen/31097014ee01e6998a468f311d855fc904890efbb4dd69bcac014de118bc77b5",
  "http://data.lblod.info/id/bestuursorganen/317126204426dc7cabb60ecb09cbe4ca4830882652884e1e5800e60231195f5c",
  "http://data.lblod.info/id/bestuursorganen/3271a48072f796bf2ba8de290226db1f985b73034e71481c44cbae04face1241",
  "http://data.lblod.info/id/bestuursorganen/3370183b7f24be2db82d3412e0e965de6c3d25acf6d7ccdaaefcaa95bc29d9a7",
  "http://data.lblod.info/id/bestuursorganen/36f5b3edfa014757c691ab27d80e4ab6858d7fa57465c0f7e513e8f36684e405",
  "http://data.lblod.info/id/bestuursorganen/39423cdccbce6ff187eb4cbf565560edca8e59e6f34ad09c72900c5aa46b0a2e",
  "http://data.lblod.info/id/bestuursorganen/39b9752ca06dbdc5c5e84d81b1717ff9447c28c5a4bd9f730a4f3f67676080ff",
  "http://data.lblod.info/id/bestuursorganen/3f92d1645e41e18e49fa01d639bca3ccc16bfbc0f17b296b7297f7f9ba2b2f99",
  "http://data.lblod.info/id/bestuursorganen/42ecf11821359d31524a2cb2c76dbf00c71063489a02ff484173e011780de967",
  "http://data.lblod.info/id/bestuursorganen/430857ac126dd1195951f6c85402cd409b2993b3dfcb9199dd40343fa57ef3d1",
  "http://data.lblod.info/id/bestuursorganen/46ddd7daa1662111b82d9b1d258708834caab8399704e48f9eb66b4f993fdc2e",
  "http://data.lblod.info/id/bestuursorganen/47205483ae75a54cda01f10aa4362621ef980e5c272702de0181e935a21b0243",
  "http://data.lblod.info/id/bestuursorganen/47657b7f0e1814d37f9b37a0c3df34794ac2409d619c0a82f83073eb7094be02",
  "http://data.lblod.info/id/bestuursorganen/4a9fb8b596062086542b1ca487e593f7c48d5d07e419e846185f4906122e7d6a",
  "http://data.lblod.info/id/bestuursorganen/4bbad63b1c9e4f6c4b75a6b38eb647960dc3b082197b8659e0df153e6004a09f",
  "http://data.lblod.info/id/bestuursorganen/4c4e625fc264798ac69aeb709918c0d2607689de1459cdebe06e9a42ab34ecbb",
  "http://data.lblod.info/id/bestuursorganen/4f1e6c38b52fb47d89d3dc2c48c0fde1643bfa174236c09b7639a38b0f21e9ad",
  "http://data.lblod.info/id/bestuursorganen/501a9488773f3a1d74ce0d766850667ed6ceb3ae2f8b4c94233c1ae7492e5dd4",
  "http://data.lblod.info/id/bestuursorganen/52787553e660abb96bc11259837217cbe4689ea95da2b6e2cd8c1701ed0b102d",
  "http://data.lblod.info/id/bestuursorganen/53a3d006ca9e231c73e2f692e1743dbf8cb79c5f80a786297ca3689ac0ecb781",
  "http://data.lblod.info/id/bestuursorganen/57c7cc1bda515f2174364cdab9fd61b494163ff5d303e83ce7b8790366ee29bb",
  "http://data.lblod.info/id/bestuursorganen/58abe570fdcb9c8d4b0a9d7089594b53e4eab8e6016e5886e59eea9e2b32c7ea",
  "http://data.lblod.info/id/bestuursorganen/58ec3bf3bf4c4a3d2c204f668b5ca133cbbcad67f5147afd815fdd689e3097cf",
  "http://data.lblod.info/id/bestuursorganen/58efd5b9a9f9d7850dad94d6d705686487d2b657b6f7a68ed511ff331a7671e9",
  "http://data.lblod.info/id/bestuursorganen/58f9718930b679603e7b85c70a1375e243ead690e37ffbea6a29d4781a21162d",
  "http://data.lblod.info/id/bestuursorganen/59e76c25e6aa1dcaf2f709b2234f415be3a084576baab2bae51d073c1ac4d031",
  "http://data.lblod.info/id/bestuursorganen/5a872bf5cd928e1dc79f6b3c6016311ce9cb054c26b026dd9554688d70aad3ef",
  "http://data.lblod.info/id/bestuursorganen/5b4fdd6252aaa35f35b73af80292e90d6c04866922f4c6973e746fee95c7d10d",
  "http://data.lblod.info/id/bestuursorganen/5d87f71fcd4c63c484618e4b109bea135e4510db0b8716ee140d991b9c9983ad",
  "http://data.lblod.info/id/bestuursorganen/5dd2f796b6f060a8469fce1f52db0964ad9b5014f2995920972d001e674d87f1",
  "http://data.lblod.info/id/bestuursorganen/604e0fcfc6d5925e67535ddea687b7f7ff57c2ad9143af0a30bcadad1309c09a",
  "http://data.lblod.info/id/bestuursorganen/618ea2d4-ac37-4cb0-850a-6f24ad93eee4",
  "http://data.lblod.info/id/bestuursorganen/63104613d91bdc083ad6d2bcedbd1d5f12d929df4c619aa84a1595ff9ef6f2e3",
  "http://data.lblod.info/id/bestuursorganen/6397aa2e084fabf560cb602583604bc1d15b9c56729beef579c4703724adc455",
  "http://data.lblod.info/id/bestuursorganen/64364fa9b483462022fc529c45e007fe2308ffd2aa6f016e92f13ec581a18461",
  "http://data.lblod.info/id/bestuursorganen/697f3366667881134e49d12926f964e9f3e424bf4f9010ea413d9d78aa66e842",
  "http://data.lblod.info/id/bestuursorganen/6a857a5b684de7f62be3ff44ddbcdc865bf941fd23d46402ec94e04855835077",
  "http://data.lblod.info/id/bestuursorganen/6b4c90a9a08365552e5eba896e17d028322a4f61ec905aeb8dfd0477ed13de6c",
  "http://data.lblod.info/id/bestuursorganen/6bdc9bce450264aeb18b443e5436e048f589324dc646827868a37ac5c1b28128",
  "http://data.lblod.info/id/bestuursorganen/6c7e8cc3841004e379abc7dda5b47670e92b0e7d45fa660a03c5562a1f4ff82c",
  "http://data.lblod.info/id/bestuursorganen/6d1b887c3ce4d92548f03818e5fc37caa11c8bcc9ba746e16d4da66f4ddf9a5b",
  "http://data.lblod.info/id/bestuursorganen/6d2b5b1f1274ad84e39a3c878a967e6cadfe3a682d69ea0fec42b0076c1a5eb7",
  "http://data.lblod.info/id/bestuursorganen/6db6f30cc95e7f696f7b0e5c4008981e4c29c6e53f8772e473fbbad2aef6205d",
  "http://data.lblod.info/id/bestuursorganen/6de96aa482b41f4bad3108034540c493ccc2ea181ca6b408155db98b878fd947",
  "http://data.lblod.info/id/bestuursorganen/6e05f9aa7782eedae42d16772a3ce2f7cabed18fe0a8e557b42d94ec0bdce961",
  "http://data.lblod.info/id/bestuursorganen/6ea0c788b6e32454a2d7de73bf2774e0b6d395a93ae8c8c75be4753741eaa38d",
  "http://data.lblod.info/id/bestuursorganen/6f59411d3b59d82f99a2b822a89652eb8b68f55d7541396efe1de5c77f30dc3d",
  "http://data.lblod.info/id/bestuursorganen/71d75d790fc8a0ab1bf7dbc277da79944c032920cc0d154502f8bb3397fc26da",
  "http://data.lblod.info/id/bestuursorganen/734a800863f1aca488a1f007bd4859ec0906056468bf368fa293c3ba865285c3",
  "http://data.lblod.info/id/bestuursorganen/7394f8d2671a5508fc7bdd1edbf7503c4598e59bea3fa2f88cdf1f02fb1c1c9a",
  "http://data.lblod.info/id/bestuursorganen/7400748488b5fd754e290d59e5992983aff2967609e0996c1e51e2fdd9e4313b",
  "http://data.lblod.info/id/bestuursorganen/7449b5330d95d5102fc0e1c7e46166b602a154a257efb9164d4ea92ef1ed9a8a",
  "http://data.lblod.info/id/bestuursorganen/753bcd62825ed3bdc4116a98c24b23221cee540712f10e86c36c63b2842eddcf",
  "http://data.lblod.info/id/bestuursorganen/76165c39131dc61b5aaa36b7b6274958f68bb8da2d892a1e1c96de9e02b573d4",
  "http://data.lblod.info/id/bestuursorganen/7716c6a7be7e61f602512fcc05e282efe47e8248c1c3c421aefd758471592a3b",
  "http://data.lblod.info/id/bestuursorganen/775398b44a2a1436c68fe3129f08db3f017093e0afb3f7e46eb206ebe703c19d",
  "http://data.lblod.info/id/bestuursorganen/780d1d247bb1bef0a6cd809c642d1855489c72d45be6ad6d3d809fb6444f6d7a",
  "http://data.lblod.info/id/bestuursorganen/78bda520b79ab18cbd9dadcc3f38a68021fa5daa539f4c58f013e727c40b1995",
  "http://data.lblod.info/id/bestuursorganen/7d100930a6efcc3e2ce306bc0a4799d237ff2e8b8b4e85a088c5dfdc2283d2a9",
  "http://data.lblod.info/id/bestuursorganen/7f2a2ddf9702fc51ec6718e43b5190547ca2337167c3f1c8e1827653352909ac",
  "http://data.lblod.info/id/bestuursorganen/840d877ccdc55036eabe5b94b2bacd4412d411b83939fec018685d0d28a6fe39",
  "http://data.lblod.info/id/bestuursorganen/844ebe915bd9edc0a1f12ea263ad5b28dce517c4b407df59ac3d81e52992dcc4",
  "http://data.lblod.info/id/bestuursorganen/87dce252ea3cdc981002def9f7654a931f30553af76e8827d853fa70f6853d5e",
  "http://data.lblod.info/id/bestuursorganen/89037ccdfa2a65b03090d199f63abeff94a8fa7771894e642350fea0f0362a71",
  "http://data.lblod.info/id/bestuursorganen/8de8a6282d8f30214b215a8216f59face417483b062e0fad683ed6560b484431",
  "http://data.lblod.info/id/bestuursorganen/8e2de0eacab29cfd72d5dbe7ebcdb38d4837ac9820044541110fe2713cc5e1b7",
  "http://data.lblod.info/id/bestuursorganen/905f565c-1203-4129-9a65-3ec0215b02c0",
  "http://data.lblod.info/id/bestuursorganen/928c437f8b132c69d78456bd7552fdb39bbe7e002ac21828d8c06a753b00b735",
  "http://data.lblod.info/id/bestuursorganen/9327afbb59e2a5afc416960a2cb566cee47600786d233924d152be3f30697377",
  "http://data.lblod.info/id/bestuursorganen/9405e6a14037aad03d3656c557567db4cd92d9c1ad10179951ddcd8674839c06",
  "http://data.lblod.info/id/bestuursorganen/94ed4f1c141ee5c448faa9d7a81c54dc339f8d5fab951b5b644826d0fa6e02a6",
  "http://data.lblod.info/id/bestuursorganen/94fecc9127412d22c80a755391fa84d39001d1f5ab4b1b1ff98c5bd5f4836712",
  "http://data.lblod.info/id/bestuursorganen/9563166704c39b22c454b51c692df6c68b317fb04fcbaf6cba2222513dec5585",
  "http://data.lblod.info/id/bestuursorganen/95d47011bc5b568418a4c4a6814465d0ecb9b86209d880f1480ed24f34df103b",
  "http://data.lblod.info/id/bestuursorganen/9600d2dd91a8a328cef8f0c73d125d0af6ca2b01f829b9795cf1cc9357e1dd43",
  "http://data.lblod.info/id/bestuursorganen/974693e1430ab4be08ceab66393ca6af0da4af2bb03e862f284b30a29a2b2e4e",
  "http://data.lblod.info/id/bestuursorganen/974a151f8aeb279ee2284938c4fb9aba2628804c50c2952c6ee4471dd2f6c506",
  "http://data.lblod.info/id/bestuursorganen/97e8cb7e2390f7e5ea64f32c2b8a8171a88e68b72c425152998dee569c7f36f4",
  "http://data.lblod.info/id/bestuursorganen/994d1744e80a335e35bd8ff12a09f309c8fe23e851e18e1a8f60c740e4082ceb",
  "http://data.lblod.info/id/bestuursorganen/99d00e889f679340036aaf3e17f8bd843e86cff4efb7d080647bd1d837f14273",
  "http://data.lblod.info/id/bestuursorganen/9a304f39dc20c55c179446242027267278c16c7063c008324a814ef9e8a0af32",
  "http://data.lblod.info/id/bestuursorganen/9d3685f172846a8d2dff6a8693ea19400d4cfab2b4df75fcde74dabae457b3e7",
  "http://data.lblod.info/id/bestuursorganen/9d5f7254da622f4cd607ed25704a02d6f75adf555f2bba19ca7a6c32dc64ade8",
  "http://data.lblod.info/id/bestuursorganen/9efcd3b21f0b865b450e70bee8b93fb8eb38e9a55ed297fd2aa0fcf61ad6424f",
  "http://data.lblod.info/id/bestuursorganen/9fbd7d000de123958b88546c208f8f0eb353ae855257b3e515df12a9a81de2ea",
  "http://data.lblod.info/id/bestuursorganen/a13ec6e428200cf40c788378a46bb852ba8d46acef8f105937529c2de3347799",
  "http://data.lblod.info/id/bestuursorganen/a258188e-6dc4-4572-9910-b157b7a4b101",
  "http://data.lblod.info/id/bestuursorganen/a2742ddef40a1aa859b3341938c44e0c7a8d0ae6be27159aee0ee24c223f6a76",
  "http://data.lblod.info/id/bestuursorganen/a522f6baadbc3c5220c153ca78c786ea3053d914b10e486861bd3756c80560cf",
  "http://data.lblod.info/id/bestuursorganen/a69723957ffcf6672e028f20cc2ccf9df716081568b0150c8b8ddf8cde63a328",
  "http://data.lblod.info/id/bestuursorganen/a6db869830b08d82466681dc56ebda4e92c0bb6b904a80092310ae8fa615f734",
  "http://data.lblod.info/id/bestuursorganen/a7f3c642b389d1b76d41abd23c4678c7f95ec7b131f3652344bfb1eb37c2c0c4",
  "http://data.lblod.info/id/bestuursorganen/a84d12c61a49edd7acc0113a0c87d137e98fea3cd2fed1a4f9886039d9755856",
  "http://data.lblod.info/id/bestuursorganen/a89397ca7ae4cb6c6ca6a8aa9873545f3b4f295c4baa6d5d71164ed2e0005d3d",
  "http://data.lblod.info/id/bestuursorganen/a8a4c004f2fb910778d1a4fc1b76a42e35723bb742a66c9d38c9b193b916e814",
  "http://data.lblod.info/id/bestuursorganen/a98ba737920e95fd76bbac1b50771d5140771b389f6fb2819c83ce8d74a1ac23",
  "http://data.lblod.info/id/bestuursorganen/abc414de400b76ec138f354d735b96ab9bd9b0fe2a7f855a8f4e6681eb6f3794",
  "http://data.lblod.info/id/bestuursorganen/ac1db7321f48b13076c1eed119eecb79cac8300e9efe34e693045b4b4b39c39e",
  "http://data.lblod.info/id/bestuursorganen/ac3ebe488685c978c7bd1158bd52a710b227e40638ca90956af3a95645408f77",
  "http://data.lblod.info/id/bestuursorganen/ac4d104f20ba3bd87d2a2b4c0c84d351f4696c1a44e9063c257fbc2d4c4db212",
  "http://data.lblod.info/id/bestuursorganen/ad933a3247ab634eb1a8c7233e77d6ea8cd2b6e1950d302832d065dcb516bcf5",
  "http://data.lblod.info/id/bestuursorganen/aefa4cd070a68caf92099a17245383d3777fb0782716f0710ab784d5912ecf22",
  "http://data.lblod.info/id/bestuursorganen/af27b7294fd445261efe714b9a289a3c24d5a35af326473895117d74c56b4d48",
  "http://data.lblod.info/id/bestuursorganen/b3505e90-6110-41fc-9452-2c7bdaf5d23c",
  "http://data.lblod.info/id/bestuursorganen/b357bd3d1cc4a21d97f26f342281dd788db3f8b1db5ab00501678ad469774efe",
  "http://data.lblod.info/id/bestuursorganen/b3859b9714acc1f6fe093b5b54262daebd150f8c1bfcf75d0f7d4418ee517111",
  "http://data.lblod.info/id/bestuursorganen/b5b90481-3fc8-491f-aee2-7f5a5ea37137",
  "http://data.lblod.info/id/bestuursorganen/b60945241da92337344b9c03a8db4a688dd7866b2c057549eb380cc00feb4080",
  "http://data.lblod.info/id/bestuursorganen/b737e3c6131e20e9277bb73649b91880760d273ac4c7f46432e78d74f36cccc7",
  "http://data.lblod.info/id/bestuursorganen/b742575dcdd155199e2ecdfb706c6c5e119c74f127f1c5819d9cb52306458adc",
  "http://data.lblod.info/id/bestuursorganen/bb2a590dc0d5820b6f85bd5b16e4b72e77de3338691fbe827070474c9a181671",
  "http://data.lblod.info/id/bestuursorganen/bc629202d91dc626925f64b5b9e8ebe3e6f19003a9c7ec7d11eb2ed94d6eaef2",
  "http://data.lblod.info/id/bestuursorganen/bcdb56fff397272bee5af7561ca4f9077e4751428241210003a257b85d0adf66",
  "http://data.lblod.info/id/bestuursorganen/bdd403037ca490e5cbfe27a0a1e809f0c204efe6c22bd7ed5b5cc164392f9a48",
  "http://data.lblod.info/id/bestuursorganen/bddbb48aa1551bde739ecdeb897434d96ed313c344de17909f5d35b80950b37b",
  "http://data.lblod.info/id/bestuursorganen/be441ba4-1930-4387-9c47-5de7eed7018a",
  "http://data.lblod.info/id/bestuursorganen/beca3d72fc1142286c87f949a1cd77ec274e744b5835a6a0c6e0b5c2006495ea",
  "http://data.lblod.info/id/bestuursorganen/c25f49b720d1e266d75375714e9256ad36f745f78e6115d69fe333122f2fab99",
  "http://data.lblod.info/id/bestuursorganen/c2665a75128ea9a10f99beb28d8769807943ddc1731781341c2e27b49f5eba48",
  "http://data.lblod.info/id/bestuursorganen/c2be0bd4872eb3c1357e4276b8454b23ea4faddb852298e0d00b4f5e5e0606db",
  "http://data.lblod.info/id/bestuursorganen/c5a29b539ddfe2a0b69170530bb79a605700680c16f45ba4e324445aece5c596",
  "http://data.lblod.info/id/bestuursorganen/c6d0fe84aeda3898b3b8a90c0188a177133d306f87c81d7bade0c66ffe061d21",
  "http://data.lblod.info/id/bestuursorganen/c8530040ef734ec23b32d5a3ef5cfc4ae7e37579a814149fe32722b9f5eeefb6",
  "http://data.lblod.info/id/bestuursorganen/cc803c53b2e0b17aac1069f5566fb8e1c8dad2f702845515a662229721803c00",
  "http://data.lblod.info/id/bestuursorganen/ccef0666a9adc745d15f60ac078989c80f0053d22c42bcfb265f276945b11b5c",
  "http://data.lblod.info/id/bestuursorganen/ce3232c33d7399f6efc93102e2184c9a8bc24a6d2fcb218582a9eb4e01dfb67f",
  "http://data.lblod.info/id/bestuursorganen/d0b460767622b2394033e3b98f453a7d77e751f1dfec423fa66745621d8fcf48",
  "http://data.lblod.info/id/bestuursorganen/d2b25a166721441f18df31fa242c7c248fec27276db1b557332683c0eae89860",
  "http://data.lblod.info/id/bestuursorganen/d4cbbd4aa8371834d99b838dcbe9563c5d04a5cc596c0abb43e491905f2c7eea",
  "http://data.lblod.info/id/bestuursorganen/d6ca92e2b60cd85c34f608528d71b1d3bd9f8e43af276d8ca77b937fbe2e78a8",
  "http://data.lblod.info/id/bestuursorganen/d7c1f51b8d3e5d0c516e902fbf394af00506050dc55025c9fd8aff1f63f05ebc",
  "http://data.lblod.info/id/bestuursorganen/d7fffe5c17d1936d46b92620d1e454f38393736988514b5f339910a17c7134f0",
  "http://data.lblod.info/id/bestuursorganen/d911d3098f2757e53fc7f05e1fd5924675d0bbd0611cae8070df22e0dcdd457a",
  "http://data.lblod.info/id/bestuursorganen/d99e6d4669d77f5dafc47c14f936bfaff31948f51fa7d4b2717b98f19511c211",
  "http://data.lblod.info/id/bestuursorganen/db2edf6c16bfc64cce8a8dc4a12ca9a7717b93b5106e80b1b3c70964163fec8e",
  "http://data.lblod.info/id/bestuursorganen/db8c3e2da85d7621120a986adc19fd8d21f501b39c01952238073abfe7d4a7e7",
  "http://data.lblod.info/id/bestuursorganen/dbbb63c4cce9333eab607e9c8e2580d31349a814b5f818d5ae0547b3280d43b1",
  "http://data.lblod.info/id/bestuursorganen/df1ee3dd1f9e55ac3aef1f6f59521d17c82be9b02855a42b2601065250b634fb",
  "http://data.lblod.info/id/bestuursorganen/df4905227c2196f0dbf5ad354a9de297a372575cceae68ed921f7e76d1e4f027",
  "http://data.lblod.info/id/bestuursorganen/e209db59f637459e77e9117c89e86c3f88f7858ead3222d6c445c9e2d4879dbf",
  "http://data.lblod.info/id/bestuursorganen/e29b2cb11e4cc072b9e836ce30cdb83db35ba3ca00b063866b07362d7e9d6ce1",
  "http://data.lblod.info/id/bestuursorganen/e35ebb3834329bf2dbe5b5108960a49a531dd4d7ed11567f0cf490d2d5bddb4e",
  "http://data.lblod.info/id/bestuursorganen/e523f6fc33863517eadba712441486c176a54ec3d48d0cf3c7b6a676dbf8fc43",
  "http://data.lblod.info/id/bestuursorganen/e5aa96a6361072422a973ece5c51bca4fd04d575a58b84e8d7696859d7a864ab",
  "http://data.lblod.info/id/bestuursorganen/e8e6478088d92c4790a3d95868335c29ea7f037dcadafd50ec2e9500756d2632",
  "http://data.lblod.info/id/bestuursorganen/ea66db1ed595b1566b21a752d882830913a8e2df040d79ed1c3cabc3ac716235",
  "http://data.lblod.info/id/bestuursorganen/eae3246bc4323b72eaaafcaffd084a9abb840a221b979771fd63cf4945820be5",
  "http://data.lblod.info/id/bestuursorganen/eb424c61502ea3fe0a36f4eb6eccd724a784990857453cb408611218861d6556",
  "http://data.lblod.info/id/bestuursorganen/ed8504ab55a8f3f10936915427de54c9394720783431025919807982859ed37f",
  "http://data.lblod.info/id/bestuursorganen/f037131484750120c7d5316a3ecee0132aadd1ff1cb63d7bf51ea51692cdf5ae",
  "http://data.lblod.info/id/bestuursorganen/f373ece36dc05b29737c0adc14de95682161bb78a55cb85f786fac3fbd5b1cfc",
  "http://data.lblod.info/id/bestuursorganen/f4c0b0b0dfee60427553987db7b5e91ca342eceab4efe12a8489e80614507c83",
  "http://data.lblod.info/id/bestuursorganen/f576f85fc480ba8cb2b84dd3fc69836b1da7d4219d21ab678bc6d5125c2b561a",
  "http://data.lblod.info/id/bestuursorganen/f5c911797cc5bcb5ef0091d9269bf9ecf51c445c90b463b3ad82cf6e4c4e596f",
  "http://data.lblod.info/id/bestuursorganen/fb7a2b953e686e4debbf684ca63086cd36cf0497558b61fa2e2549db5837e84d",
  "http://data.lblod.info/id/bestuursorganen/fbc92fa8d7898da416d9c5eecffcc1fc35ee60277403b312c840512f38055d63",
  "http://data.lblod.info/id/bestuursorganen/feae893ed66a9d4d5e184c3ac0de34427c667a1c7a96e76b55881628854911be",
]


def sparql_escape_uri(value)
  '<' + value.to_s.gsub(/[\\"<>]/) { |s| '\\' + s } + '>'
end

def sparql_escape_string(str)
  '"""' + str.gsub(/[\\"]/) { |s| '\\' + s } + '"""'
end

def batched_query(repository, query, values)
  count = 0;
  batch_size = 10
  values.each_slice(batch_size) do |batch|
    query_string = query.sub("REPLACEVALUES", batch.map { |value| sparql_escape_uri(value) }.join("\n"))
    repository << Mu::AuthSudo.query(query_string)
    count += batch_size
    puts("#{count} done")
  end
end

def add_bekrachtigingen_gr(repository)
  puts("Adding bekrachtigingen GR")
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000011>.
}
WHERE {
 VALUES ?org {
  REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "eedaflegging"))
 FILTER(CONTAINS(LCASE(?title), "gemeenteraad"))
}
EOF
  batched_query(repository, query, $gemeenteraad_org_uris)
end

def add_bekrachtigingen_burgemeester(repository)
  puts("Adding bekrachtigingen burgemeester")
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:title ?title.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/7b038cc40bba10bec833ecfe6f15bc7a>.
}
WHERE {
 VALUES ?org {
  REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "eedaflegging") || CONTAINS(LCASE(?title), "aanduid"))
 FILTER(CONTAINS(LCASE(?title), "burgemeester"))
}
EOF
  batched_query(repository, query, $gemeenteraad_org_uris)
end

def add_bekrachtigingen_voorzitter_gr(repository)
  puts("Adding bekrachtigingen voorzitter GR")
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000012>.
}
WHERE {
 VALUES ?org {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "voorzitter van de gemeenteraad"))
}
EOF
  batched_query(repository, query, $gemeenteraad_org_uris)
end

def add_bekrachtigingen_schepenen(repository)
  puts("Adding bekrachtigingen schepenen")
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000014>, <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/59a90e03-4f22-4bb9-8c91-132618db4b38> .
}
WHERE {
 VALUES ?org {
  REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "de schepenen"))
 FILTER(CONTAINS(LCASE(?title), "verkie"))
}
EOF
  batched_query(repository, query, $gemeenteraad_org_uris)
end

def add_bekrachtigingen_bcsd(repository)
  puts("Adding bekrachtigingen BCSD")
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000019>.
}
WHERE {
 VALUES ?org {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000007>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "leden"))
}
EOF
  batched_query(repository, query, $rmw_org_uris)
end

def add_bekrachtigingen_voorzitter_bcsd(repository)
  puts("Adding bekrachtigingen voorzitter BCSD")
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e00001a>.
}
WHERE {
 VALUES ?org {
  REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000007>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "voorzitter"))
}
EOF
  batched_query(repository, query, $rmw_org_uris)
end

def export_besluiten_links()
  repository = RDF::Repository.new

  add_bekrachtigingen_gr(repository)
  add_bekrachtigingen_burgemeester(repository)
  add_bekrachtigingen_voorzitter_gr(repository)
  add_bekrachtigingen_schepenen(repository)
  add_bekrachtigingen_bcsd(repository)
  add_bekrachtigingen_voorzitter_bcsd(repository)

  repository
end

def ensure_dir(path)
 unless Dir.exist?(path)
   Dir.mkdir(path)
 end
end

output_dir = "/app/exports/"
ensure_dir(output_dir)
repo=export_besluiten_links()
timestamp=`date +%Y%0m%0d%0H%0M%0S`.strip.to_i

path = File.join(output_dir, "export-bekrachtigingen.ttl")
File.open(path, 'w') do |file|
  file.write repo.dump(:ntriples)
end
puts("Exported #{repo.size} statements to #{path}")
