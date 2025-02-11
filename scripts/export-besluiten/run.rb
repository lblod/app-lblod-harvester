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
  "http://data.lblod.info/id/bestuursorganen/0c7be74a14f22ac2ac4f07dae6ff612fdd8549de2bc2a92a46f72da1040d5efa",
  "http://data.lblod.info/id/bestuursorganen/c13e8a28c36fbc418a181985b3540965846aaf60eb42b065fc5868c19919bd03",
  "http://data.lblod.info/id/bestuursorganen/66d193e0e9f1ba7f85050506daf6c8354db46869f74407390cbade3bc65d8ac6",
  "http://data.lblod.info/id/bestuursorganen/80e9a32b51ab2a52be1e99b180e913c98d42d1ed23901717c6f704d76b9aea18",
  "http://data.lblod.info/id/bestuursorganen/bce514de4b84d1f9c3f346c9cea022e71bf4a0d3057e3bcc9363feb66731934e",
  "http://data.lblod.info/id/bestuursorganen/b9bca7d2316e6ffccb4b581e9b4def3f562575f59ef6704982777d7faf1a17ec",
  "http://data.lblod.info/id/bestuursorganen/16bdb1a41cefb2ae574505159c29eea6c4ee4925e62f76ac58113facf5acb100",
  "http://data.lblod.info/id/bestuursorganen/7fc6567674cf853ffe199134e5450bf6b2428fd8dd90f4717127549d90d65dfc",
  "http://data.lblod.info/id/bestuursorganen/95977ebc4a83ba6c9c03176359ca84c1a9fdceb582943dfd60dc4f3aad6ad979",
  "http://data.lblod.info/id/bestuursorganen/1b52f9605f81a987d65e2084f3f05e995e7c9da7d17e7de4a240b23d6df024bd",
  "http://data.lblod.info/id/bestuursorganen/67ab66ba92e5899909ef4fded2d0129bf8f60048fefa6f60abba777bb9f4b4d3",
  "http://data.lblod.info/id/bestuursorganen/9226943081f2ef6cdbf8bf54127b908ae045ab3e7bb51c1b34476d08d85c6ddb",
  "http://data.lblod.info/id/bestuursorganen/4be516033ece64a4efa8d021ec7a7ae9a749482c00a5be81b7615733fd2a767a",
  "http://data.lblod.info/id/bestuursorganen/6dc36bdc-8cd4-4a6d-b4c7-9e7982cd2b3b",
  "http://data.lblod.info/id/bestuursorganen/571a4931687d20625b42b9f805b3d4f2ac192608bee34aebd43d326a31f110a7",
  "http://data.lblod.info/id/bestuursorganen/281b5474-0f6d-4ac8-94ef-55afd338d3f8",
  "http://data.lblod.info/id/bestuursorganen/b2dc2c7990b3ef28eabaa433f43c36a146b3624b37e62b9a99729932a401c254",
  "http://data.lblod.info/id/bestuursorganen/8a2b0238e595d1678f35f73125815717b265bfb4d474d4e24673d9bb361899d3",
  "http://data.lblod.info/id/bestuursorganen/19191713536430d3abdbf509a5822adbaecf04d17aeb83d464088bc35bbec204",
  "http://data.lblod.info/id/bestuursorganen/329f9a960a3cdd0554eab1e5dabbe991fd554b4b3580f3126e562e91244e4ad8",
  "http://data.lblod.info/id/bestuursorganen/907a95e34659f42e07a67f5a6b78eaab85278812d99023568b22031d8ec271a8",
  "http://data.lblod.info/id/bestuursorganen/47b734b9d5f2043908e7f083f5789989502f795c220ca339e84f8ef60000ae75",
  "http://data.lblod.info/id/bestuursorganen/eb0938ca78683770ca60502617d66956f49e537b3d5f82f9cb6eb22ca8c24bd9",
  "http://data.lblod.info/id/bestuursorganen/5c145382e54050482c29c263534deb17d3dd5cb606c9b2bda7d93ba98984007f",
  "http://data.lblod.info/id/bestuursorganen/ad34c9bdcb89b49d83ebd2430dd56e6fd4470a10db30b2f6d612644e9900acb7",
  "http://data.lblod.info/id/bestuursorganen/a05101e01b844e9f58aeb1222d8209b19135ad4faa751969a59331d61bc9b721",
  "http://data.lblod.info/id/bestuursorganen/8db621251c34e0234353c5c666998229b243565d29e42501c8df974437c0cf5b",
  "http://data.lblod.info/id/bestuursorganen/0ab3bff1d4a0789f15d539f5c41c597e4675d192c1feb5a71d336e5ef5450ea4",
  "http://data.lblod.info/id/bestuursorganen/e1bdfec06e5407566b72ea6a1a9e89c82a1d5a81d1461772761e0974b2ddebef",
  "http://data.lblod.info/id/bestuursorganen/7488a4cda4a5443d98e7e3a98fc6918600ea0c78bb79115c140275132075f9b8",
  "http://data.lblod.info/id/bestuursorganen/b252a61866b65a5783e9d95332acb70eeb2a31ff62821075cf9640f88d05faf7",
  "http://data.lblod.info/id/bestuursorganen/d9b9d3e7393e131d703d3329d6664cbeefb426a60503718e5210c18106306b35",
  "http://data.lblod.info/id/bestuursorganen/657ba9f336f38c795b1024a36ccf5ab897fd681980556b94b8196e3379b16931",
  "http://data.lblod.info/id/bestuursorganen/8be6f67728e602e926b80f2a7baad4b03a5d9f67a435d5364596c5252d683004",
  "http://data.lblod.info/id/bestuursorganen/28af1d444062b7a1abcedbf9e701a49db7ebc89da68ae2663a499c31b87d9914",
  "http://data.lblod.info/id/bestuursorganen/f9aa36f7cddade894d400ca3dd5940b24783a56a7c18fdbb640c89d4f71c6aff",
  "http://data.lblod.info/id/bestuursorganen/62aae674defd886c1f5a288d618a1c9293f80d3e4e85251d1152077605c0350c",
  "http://data.lblod.info/id/bestuursorganen/2ef9f71f9c941890226ee998184d23735409d42ff6247b6ac6040f7420ea2217",
  "http://data.lblod.info/id/bestuursorganen/b4b2abecb53877f8fc34287c54901fbf1bf9eb78cd93a2faa98996778d2bd636",
  "http://data.lblod.info/id/bestuursorganen/d3e32a6277593d6c0f9614d747d7d043772dc01f81f73f317fe9890ef19a1c99",
  "http://data.lblod.info/id/bestuursorganen/346ea6394968bac4dc1320072d6c26496016007f31d544ed928ddebfcbdf5950",
  "http://data.lblod.info/id/bestuursorganen/92e93c2b7c3182cfef9f9ad972281650e4e35a37da9e4fdfe7f9121b3ace40f8",
  "http://data.lblod.info/id/bestuursorganen/634bca9e647182bb443009710251e9e9b4a57ba5b952a149a4272af2a75f578c",
  "http://data.lblod.info/id/bestuursorganen/cbba604cec2e3b01d0407af82d2f690a064415fd4da0a0a3d236421332d5bd3b",
  "http://data.lblod.info/id/bestuursorganen/a7e1d6ec3df3c09a4ebfceb89c32ed392d427f09bdb7d50670c58733a53e954f",
  "http://data.lblod.info/id/bestuursorganen/6444d34273154e2fd79584958c08f72b4b1d5fd7deb54bb51fef18ff8334ac88",
  "http://data.lblod.info/id/bestuursorganen/71cad994b49a6da493b23f8d10a9e1da3f7a6a2f0d4fea95320f9e81902eb8ca",
  "http://data.lblod.info/id/bestuursorganen/8e000a7fcc12928c01e4bbbbd6f7aa10568f7995f15cd49588f87b06c8f0407c",
  "http://data.lblod.info/id/bestuursorganen/1e5a5d647fea766d1675f92e32dda7b033f448cb2a7ad74c6b404d5f55197b66",
  "http://data.lblod.info/id/bestuursorganen/e12951526329cac1df2d675b4553204c6a0a7919f5eedd20e05bd0a00f3b199c",
  "http://data.lblod.info/id/bestuursorganen/1d19f3592ab0b26e389df2c9bbdbc02baa1f4a377e9b627ef4bb19e7fc62b2c6",
  "http://data.lblod.info/id/bestuursorganen/28302e87a905fc705abeb338d8a60b2f91592d731e788068dab96e8c7fd43a3f",
  "http://data.lblod.info/id/bestuursorganen/a78f1ff5155659148e7e374de896a139ddbeab5165fd82e773c6397946cc711e",
  "http://data.lblod.info/id/bestuursorganen/88a7ede6b3efe8150800d85add54a8e8d766dca0a79017db4ced771a2cec57eb",
  "http://data.lblod.info/id/bestuursorganen/1464d86ebccb90edb95cad4e465d702974e7dffb73b83119e136a663da6f6f23",
  "http://data.lblod.info/id/bestuursorganen/fd6919be76b50dfef7afe9ffe37e205eec2f66b5243828e03c5f35600aad088a",
  "http://data.lblod.info/id/bestuursorganen/dda5a767bab320be612d8fdf8a9ce3cf146b94271e38c32be95107d9f80bc7d0",
  "http://data.lblod.info/id/bestuursorganen/069c2d85a85d90ae4452edaafd0ca6faea6b6f528682b7f7116f07f9dd46d089",
  "http://data.lblod.info/id/bestuursorganen/8be7e66420576ff2cfca605212b56d011a856efd28c6a1f2d84a43ee66d4bb85",
  "http://data.lblod.info/id/bestuursorganen/892c5d0b4bd9f5e68d4bc7ecc2ca1b48c542cc2e66d1cb11752fdf7546fd6d5b",
  "http://data.lblod.info/id/bestuursorganen/018d14c32c0ff31bdc4e1d362850c9f0a90ca3f612ec4501e03d0336964f32d8",
  "http://data.lblod.info/id/bestuursorganen/5f3816c6f81abd27f3499dd5ef8ce0f4e0eac831c1ddc6a49206d0b51dba151a",
  "http://data.lblod.info/id/bestuursorganen/af28490e0510734dbbc3421115ef5a69b714055d45a2ca04a8e66238649fb343",
  "http://data.lblod.info/id/bestuursorganen/23f25c418720794a2eadcd6e69cf0789301bcbe1e2bf84e017a6507a150c73ee",
  "http://data.lblod.info/id/bestuursorganen/95061e14c047d9d53d830da78e27d0cc5cbdbf818278d84deef9c725637b6aec",
  "http://data.lblod.info/id/bestuursorganen/5eefdcd8f3349d311af512754f652aac0cd67a71afae16858564be1031a9c3d9",
  "http://data.lblod.info/id/bestuursorganen/3ad1e79e9d991df99b5fd7a1df379aeb9ba28972b0207d2b710d4d6177746b2c",
  "http://data.lblod.info/id/bestuursorganen/c70415f074ca1fee9116a1f4ff7648bff7d96414e5355c368edc501d4277ed86",
  "http://data.lblod.info/id/bestuursorganen/4a9d2bf87237bc404179dc5af670ad024814027f98b030180770d08622fb9c8e",
  "http://data.lblod.info/id/bestuursorganen/a932dba2b3aa3bfe4cd23cb54e918456e058018141d349f983ce1546889541b9",
  "http://data.lblod.info/id/bestuursorganen/82a626fabb46f20773515f4d611ce935ff3df28ec313bc73ca6a774b3e5df263",
  "http://data.lblod.info/id/bestuursorganen/0b26ba6db5e6c2b81747df1c85e04753a88e0dc3c07c2de2654ee8f9dec34d69",
  "http://data.lblod.info/id/bestuursorganen/9744bb1803b45b0648a80b5ec99f29dcc1570b4bc9192ca0ecb4f98c8a81ffc6",
  "http://data.lblod.info/id/bestuursorganen/a370900d7e0b1a62e47c70bad6dc2dfe8b7386e71c25f5a18577ad7f7d0ddb6c",
  "http://data.lblod.info/id/bestuursorganen/8c9e7963c6f8ffcdfe0860d88ce1a1308285508f6c22662b8a099a494db5221f",
  "http://data.lblod.info/id/bestuursorganen/1af1d88b901a58aab648944695820840b5b3d3c3c1a897272d03d84061aeba65",
  "http://data.lblod.info/id/bestuursorganen/dbf3b1f02b1e6532630af26f0caafdd78c2285407d78b264c7a3bc127de66c44",
  "http://data.lblod.info/id/bestuursorganen/7537befb345ecab9d5cf51f9e4795844990cc9e5bcfbf4b4b3544b84927688f8",
  "http://data.lblod.info/id/bestuursorganen/40f1e31e13703e6081c54b24ec06ecbdc67b0f601fac142ed64ab37ce9f886b8",
  "http://data.lblod.info/id/bestuursorganen/75a8672cf876b07b4168eab75351835e8301942227b6abf3b27a9b26d8820ef4",
  "http://data.lblod.info/id/bestuursorganen/239ad1d2705e7cd03f2cb6d8551c7e03de61fc44df370249686e93c95df6febe",
  "http://data.lblod.info/id/bestuursorganen/7e10f77d310de5ccf367b0ec879469121e4774656f9b57cb8f82497e746261a1",
  "http://data.lblod.info/id/bestuursorganen/ec36ecbad8e36283d94eea448c516c1b79bdf5e757c7ee5911de204d364bb424",
  "http://data.lblod.info/id/bestuursorganen/68f0d955434bb85019bb7a75a10a7b0822540a9f27eb8bf1c4f6d30eccab262a",
  "http://data.lblod.info/id/bestuursorganen/47ef5b203fcb576f3345d43baa5ed97ee595c4c5f5f18450051a6f5b7c1fb687",
  "http://data.lblod.info/id/bestuursorganen/fcf4e01b53cc8fe42edf63d7294e67b094c6349e4d22cb18da44e961858fdcfd",
  "http://data.lblod.info/id/bestuursorganen/62216609d9175d61981a8127a56ebf9ff62a584bb3199693cc5ee7a7a035a1a9",
  "http://data.lblod.info/id/bestuursorganen/94f56ab8d5a72585272bd50fe3433dfcdbc9d8a2ac69985fa455cd94b5087e5a",
  "http://data.lblod.info/id/bestuursorganen/234f6dc61d9b8551933c33b9fb5e8d7b07f6eaa2c6069176b78da676747cac39",
  "http://data.lblod.info/id/bestuursorganen/411bc9c6050e181ced0e1acd706bd606f7bfeb3873c2daee4551a5d6d598f179",
  "http://data.lblod.info/id/bestuursorganen/58d0f2a00ebfb1c4938c8103ea7409e7a4008b10fb0ec09c0cf38c0742874b5c",
  "http://data.lblod.info/id/bestuursorganen/4d9c89bb-446b-4602-b32d-292b173db00b",
  "http://data.lblod.info/id/bestuursorganen/59b1dacf1caa0dd64b2a30cb8cea4c20ec24ea245289789b3dcb24ecb4e272c8",
  "http://data.lblod.info/id/bestuursorganen/35aae96c7eb01431477c791135870e4c16f8b860cc8ed07f461fef79da4e0f34",
  "http://data.lblod.info/id/bestuursorganen/66bb8cc804315f138b468242987faff2c5065de2b593c627cd4c215a5ca805b8",
  "http://data.lblod.info/id/bestuursorganen/ff84de231f1151571894c96ea3a85e5fa712e3d96720bb974856ba3fcce27655",
  "http://data.lblod.info/id/bestuursorganen/8e701cb7-3e65-44ed-a537-153ba2f6e03f",
  "http://data.lblod.info/id/bestuursorganen/b61d6817a6403a89cb4bc86e647ada5fa29636a94ec9c7ddc155c61c0af3101b",
  "http://data.lblod.info/id/bestuursorganen/7c0afbbe0aeedae7f6ef17c5c03ad7e201173b86702715d99cf1f6beff906268",
  "http://data.lblod.info/id/bestuursorganen/ba8022d02189a3f1dcc9bc99a53e85a25359fc757a971e8b5a08aff166e30733",
  "http://data.lblod.info/id/bestuursorganen/85d10db6cc137a0dbafce634963d902416a9aca0422fe4d2a23cc601f96d64da",
  "http://data.lblod.info/id/bestuursorganen/6f8bb8edb83dd3a314d745abcd6218df81596c43d99deea3a698d6e38fe36f7f",
  "http://data.lblod.info/id/bestuursorganen/7851a8e10ccf8af2084e83b7762d2c35144b30c8e3e6a2934e19204b7c25ab6b",
  "http://data.lblod.info/id/bestuursorganen/152d73fb8b3c1c61deebe03d9a51b17fe489c0473cf1f27238f1c0db90b060e6",
  "http://data.lblod.info/id/bestuursorganen/64ae56f2583e79613d1f50ea9f68e46ad2d9525201a66339cd6007963dd91406",
  "http://data.lblod.info/id/bestuursorganen/dc8a67da0f76c3ac58b8440a9ff40a01be144a5c2d968de00d4a9d73da2ac9fd",
  "http://data.lblod.info/id/bestuursorganen/c0bebcd20fd16bbfb1f63a8e193899a3b6720f1290b0759f593656d563a29ffa",
  "http://data.lblod.info/id/bestuursorganen/51eea0597bfa1f4422e598517d29ccf1b23f7ff45aaa38c5cde17bbb16c611d9",
  "http://data.lblod.info/id/bestuursorganen/d6e9b33609db94189c50590fefa1567f01b620360658043b26cea1a03f7a784e",
  "http://data.lblod.info/id/bestuursorganen/53cbbc27fdd8431c62c813dfb2c2a977a887f88f63d2a5819ec77d5f386c9a3b",
  "http://data.lblod.info/id/bestuursorganen/e20656ca33422831009a17e60434fd0bc676531cf8841073090f1aca843149b9",
  "http://data.lblod.info/id/bestuursorganen/1b115060a2bff99b4746748cfc96f004f7dfdd4ce0258b161f15f67ce5056eb9",
  "http://data.lblod.info/id/bestuursorganen/7e8ace8c364dc8e2ca87ba6fd4ca3151c83b70276cbe57986f34fb8bcb9d3cf3",
  "http://data.lblod.info/id/bestuursorganen/c65c42d6bcdbf397aef3c0749458f21309fb3a395c58c58594debd2372d578b4",
  "http://data.lblod.info/id/bestuursorganen/fe61112d1d440e4af10efd6d7e51a21287e8422d7d5637e4122994ecc8c8b643",
  "http://data.lblod.info/id/bestuursorganen/a36303d124315bbae6ce66c526c03d6d1ff01bd0399c49102b046c419ef753ff",
  "http://data.lblod.info/id/bestuursorganen/c768718c762b8279ce0d1fe8954feaff5894d1b5a3a7a9ae02530e724009ce3f",
  "http://data.lblod.info/id/bestuursorganen/02f5f7d1afbefef7c397a4e3de2907c7026aea3878ca992bbcb989a0e32371cb",
  "http://data.lblod.info/id/bestuursorganen/33cfc6532bd3b40de7bd5f3cdecabf5a6d1284e65d4a4ba95a4d5f3b8f62c106",
  "http://data.lblod.info/id/bestuursorganen/501db78911099931ff29847954af79fe846ec29bc31585b7465b0a2c39d40ea0",
  "http://data.lblod.info/id/bestuursorganen/7a263931879484ca3c517e63720f55540770e1b2e587caa6d36ae55a767aaa02",
  "http://data.lblod.info/id/bestuursorganen/120ef3e172052e79962881c44b1b72cd18c6c82d8fe57e8fb1909a0805518158",
  "http://data.lblod.info/id/bestuursorganen/fbdcf83bae96d4c18e6f64801f2cb24b0f4df256bdb02055fc3c59882d91d061",
  "http://data.lblod.info/id/bestuursorganen/0527614538d2d9831b58babbb1d1de3fee3f82f24dd182f39b7b10a6a4132ed0",
  "http://data.lblod.info/id/bestuursorganen/d5f648b579426c2c9b93b92237f089f22a1a3e3face1b0d37e5592190b45f05b",
  "http://data.lblod.info/id/bestuursorganen/e5b179a81b91457115f0a1d09e079373d783b76104d7bb4e61ac8d1c46dd2a2d"
]

$rmw_org_uris = [
  "http://data.lblod.info/id/bestuursorganen/775bbfd15b5a2b1bf4a349d2090ec29345def6e887774b8043e8e47caf95d683",
  "http://data.lblod.info/id/bestuursorganen/dbfea2c4721cefbc1668fab0b6e74f0162e94413438d3f7e6ad5261dc60c12b5",
  "http://data.lblod.info/id/bestuursorganen/9586913cf2334bef45284568583f9e2e803ace1b0226c82a36046c9da1935b7e",
  "http://data.lblod.info/id/bestuursorganen/07bf58f2240ba2111d6c8adc37081c3f935fa513b17d73c6484c714ee504d323",
  "http://data.lblod.info/id/bestuursorganen/2afecba6cfdccd098ced1091080d8b44ae3602828a99eb5af494993feaa2932a",
  "http://data.lblod.info/id/bestuursorganen/cca803bad5b2dca161e4c3667b5fd43e022e65e71345498d2c3d56d24f6b37d9",
  "http://data.lblod.info/id/bestuursorganen/a63dd013e177e9c129df740b431ae27a2970f6b80ed6082cc99fc033d10bb5c3",
  "http://data.lblod.info/id/bestuursorganen/959b322dea53b7a155ad564fa2683025fa4645ec926c98d4e7f18728c000e24b",
  "http://data.lblod.info/id/bestuursorganen/f6d15f442cfc588e78049397db2af6681c6d07c44fa6a7052f5443a6a9f01d05",
  "http://data.lblod.info/id/bestuursorganen/79944afe6bd4d046699d3ec63cf5219ad2ef75a1657105112f04c2128a6a250c",
  "http://data.lblod.info/id/bestuursorganen/76461ec55faf7cbb9d9551c6092521d98a6b99b1472227a5d2b556c4f3a18296",
  "http://data.lblod.info/id/bestuursorganen/86f08a1b054510adfcfdfc8b540146cc0af0208c9278ff1e40375f69790f0d8a",
  "http://data.lblod.info/id/bestuursorganen/515fc9ea535d05af2f36feb6a11bda282b59e2fd5d03cb60497e314afb103791",
  "http://data.lblod.info/id/bestuursorganen/77494a186d55db352735533c7ecab51bfac0cb828549a185670e3aeb2cd0cd0b",
  "http://data.lblod.info/id/bestuursorganen/2cfad992c37f5879b9f24dabffb75b189b9a30b876e845518cb9711331e5cd6a",
  "http://data.lblod.info/id/bestuursorganen/f4c8d080fd469c734dc23e2082b1a4583cf183aef55ccd786dbd75ec0dc0cf00",
  "http://data.lblod.info/id/bestuursorganen/3b4550b78c92888e7d062aedf929bb884144150c3bce9fdd1b3bb3be0dcd2c7f",
  "http://data.lblod.info/id/bestuursorganen/22eecc6e5d4d727823678af36ebf0277330c27c07c81b866bbad80542b3467f8",
  "http://data.lblod.info/id/bestuursorganen/563d55d6a82e1c741cf7e9f7e781160d0f6ae3f643f4bef16b2aa009567aed6e",
  "http://data.lblod.info/id/bestuursorganen/045ac53d8e9746fa11750b317020a0934c63880693a5c345cfee44a400ff6448",
  "http://data.lblod.info/id/bestuursorganen/2dff23972c02297330a8f1e66283e273215f75d149060e4e3ee9e0f8434f78ee",
  "http://data.lblod.info/id/bestuursorganen/764424844dc10d52a55d638e8a22d01c725861d221c885ad983f66094fda2c22",
  "http://data.lblod.info/id/bestuursorganen/09b083e5133a70878001a63565f79c379bef8fd95c5426f32053f8dd6564af7d",
  "http://data.lblod.info/id/bestuursorganen/2ab819d1de14a20d69e2063fa01bdbb0cde92ef54e4395dfd95dc1778ac93e6a",
  "http://data.lblod.info/id/bestuursorganen/68223fd368baec901634a8722b72323ac055691f77036096f2f30d549c1fc930",
  "http://data.lblod.info/id/bestuursorganen/660e004e9739c10608a9f14734cabc97cacbd8e327f4e044c304be032a0f45f5",
  "http://data.lblod.info/id/bestuursorganen/1c0cc2012889ea84e8ade7cc15d3e9025c7e0ec873ac6504851a4d5b26e7dbfd",
  "http://data.lblod.info/id/bestuursorganen/64e93a089f0098acb19f851bd568c11a365d334e8e1b79c069d63d7f27f14232",
  "http://data.lblod.info/id/bestuursorganen/6eb0b079e9f292e851f16f5dfa98c3c2faaeef94f19fd3907b433d6b88c63669",
  "http://data.lblod.info/id/bestuursorganen/2692988cd5204be0d842a1cc60661aae07284f931f93871ef027e53d3b7c27c7",
  "http://data.lblod.info/id/bestuursorganen/c7029190fb15eca5891d5db572e53699b353037cb4ef8b697b9a7cf38bad6973",
  "http://data.lblod.info/id/bestuursorganen/7da2713105b1eee03061de1eda8f1870c620f914c19b364ac0c32c44d9b41789",
  "http://data.lblod.info/id/bestuursorganen/9e73295d-41c5-4232-a84b-04cea0e54b09",
  "http://data.lblod.info/id/bestuursorganen/3c3c9d6119895e202ee8ebbbcea575544bd16b11e9a8a40fad0ee4aa6568b314",
  "http://data.lblod.info/id/bestuursorganen/477187a364a5813d7a5c729e86737551752af3363546fb68d3bdb614fbad1ab3",
  "http://data.lblod.info/id/bestuursorganen/facc6a43-b3cc-4184-89e0-c2fbec9f178f",
  "http://data.lblod.info/id/bestuursorganen/33f3a994677e463e7944c4f56aa238fec543221328bd3d20af1b0635af0af40c",
  "http://data.lblod.info/id/bestuursorganen/8cf1f454cc0f28dfcd94297559bd0f98c404fe336015dff4647cf733fcfc6d77",
  "http://data.lblod.info/id/bestuursorganen/2e8e8b6a577c5065b4f221d28521faf8aa0696e73d6b8794966022b37f8a76ab",
  "http://data.lblod.info/id/bestuursorganen/41779cbce116e138821a99015bf57b9eebd9869e59ee22f69c9f83a15a44b40d",
  "http://data.lblod.info/id/bestuursorganen/ce6053b456e04b393b19d65bf56a9c274b96ec6758377805eed04f4a004bc653",
  "http://data.lblod.info/id/bestuursorganen/489e14197fc61e329935cc742ad8464ec3c313bf32cbf0d4de4fb05041826e53",
  "http://data.lblod.info/id/bestuursorganen/1904b4a6de468b726f178bc36f635f9958442905bfa036aa6a2cf3d0565bb790",
  "http://data.lblod.info/id/bestuursorganen/79bdc2aeb417769e4af8266662d2107c8d89b31ab1b4a35c3e00298f5c83f15a",
  "http://data.lblod.info/id/bestuursorganen/d591ea7853c0c5254e57d9b20b3f91d4829adda08ea6dbe73c77a07331993c08",
  "http://data.lblod.info/id/bestuursorganen/b9f8af2298d87a7296d87e7c730d811d19f4325d4b091166bdca936730adc761",
  "http://data.lblod.info/id/bestuursorganen/d8a6edd2fda09651209e497867a44b2ae7670d83135c0122eda82bc8feaec074",
  "http://data.lblod.info/id/bestuursorganen/8766349f5916a5e555968531fd4407f21b6fe8272f7a9e063700f7f477eba566",
  "http://data.lblod.info/id/bestuursorganen/8100bc19a77b618b2a43a8242860e8d924d5855c224808e0020dd7ad64b4aabb",
  "http://data.lblod.info/id/bestuursorganen/00ccc04291e6e7e4a2c56d590c32dad844ddd915fb585eeef8111a998d4730ba",
  "http://data.lblod.info/id/bestuursorganen/41c198e03201f21597d29be7ef9d7c5ce3cb4d10b513ffb689a6c109ab722cfd",
  "http://data.lblod.info/id/bestuursorganen/dbcee0db-e76b-4a23-8973-3c2588a46f7c",
  "http://data.lblod.info/id/bestuursorganen/e3dcf110a4aeacafb7943308f5fbd8dd4c3540de369c3b963ea8ceb22bf8631d",
  "http://data.lblod.info/id/bestuursorganen/31801f4f9e0ab9254edde3fdea4255886609ff0e505c7fcb25c4abf3cf3accac",
  "http://data.lblod.info/id/bestuursorganen/cbacbb67319ebe78742ba1c47fa8e465c74ada9a0525a93d29a0c75be94f83fd",
  "http://data.lblod.info/id/bestuursorganen/aceceb906ac5eee6dc8519ace4a4cfda85f430065788668f4adf20b93d5cc1c3",
  "http://data.lblod.info/id/bestuursorganen/18eadc351c893d93fdccc7dade9b5ed8eb64bafd7a486a9d2d2626cc320a5630",
  "http://data.lblod.info/id/bestuursorganen/fe049aa06b1588c460991887fd8846c96afb59331e3f625318887d6bd5e93e2c",
  "http://data.lblod.info/id/bestuursorganen/6eccdc8616b16c761978ae60a3553775e03cf54e4ded720a973ba3febb4d6ea1",
  "http://data.lblod.info/id/bestuursorganen/4cfebb587fb1b7d45a1ccc60fcc98f85e2dc56314a06a18aa44864d8438af06b",
  "http://data.lblod.info/id/bestuursorganen/b5a6b634bf942f417b09fda2120781f11a1b0830ba51049fbfcc651bf6b558c3",
  "http://data.lblod.info/id/bestuursorganen/157642145ad261dc6cefa33170bc6bfe4c58367db6ae835b6d642f6e13c80cf9",
  "http://data.lblod.info/id/bestuursorganen/b4f424cc558acb4802915ec36c080abd383654b521f84aba1508c5c26a21b6a7",
  "http://data.lblod.info/id/bestuursorganen/2691f26ea289b593a0796657d45180dab3ddd517ef5c7d3e5c4cd1d21e9c79c5",
  "http://data.lblod.info/id/bestuursorganen/b5ae8d6538c4cccbd29c1427d857254347f2a0f8fdd068687d601499868dfc6b",
  "http://data.lblod.info/id/bestuursorganen/0b5879c825f054d444c6a0f6a4812c5fef9086e943bbb89e0bf31917a1740372",
  "http://data.lblod.info/id/bestuursorganen/dc586db77fe17e453d3824427f1bc11d0f415e0d8107f80007780f4f7d0f5f67",
  "http://data.lblod.info/id/bestuursorganen/db82e2b2fe51df4a963c21a27562bf7da2c58c03fad8321e908ce44d57f3337b",
  "http://data.lblod.info/id/bestuursorganen/34d29a54800281139535dbf5ac2b6bc0dc5c485b7ffcce2706d15b88c5c9d349",
  "http://data.lblod.info/id/bestuursorganen/94a6e5daa492a94eaa2985065a9ca93647d2cf2a61d484a37a3900172f038f4c",
  "http://data.lblod.info/id/bestuursorganen/846db23c8722ef9f8b054f80798d829c431739a75edf82ab36ecb7bd1817c9d9",
  "http://data.lblod.info/id/bestuursorganen/8ef375120c339e2a346c301c6412a37a61b4a1e38039d1d375a3ac2b41984541",
  "http://data.lblod.info/id/bestuursorganen/63a0a18769b92b0cb282dd2c454c09309c19cbfe728ebe864db4807432143f2d",
  "http://data.lblod.info/id/bestuursorganen/6ef03f386050386d3a78ef84ebfdef89ed3b193a6ede3db48c9b3f22efcc06a4",
  "http://data.lblod.info/id/bestuursorganen/e87ca82adb1d09fb1b8bba869c82c36a3eaa09fc9fdf7958f82332665548592f",
  "http://data.lblod.info/id/bestuursorganen/5323703362d199700c205cc8a9b02ad4c671e105652038aad48081e319a32271",
  "http://data.lblod.info/id/bestuursorganen/6dcb2bfd4515d2fc8c752df965236d85d0ad8c24d0584a256673af924ec14fa4",
  "http://data.lblod.info/id/bestuursorganen/f082015085a14e6aa7e952ff785881196421cf7c91e634c6de3bf59deca4d45c",
  "http://data.lblod.info/id/bestuursorganen/94070feb1e265fc6105126c22fadac72f7849de57c7bd23e4d110ca966e78721",
  "http://data.lblod.info/id/bestuursorganen/674dcbfa372e7ae503e0b443db5c81991f206945b8bbfb49414fca6741d43b1c",
  "http://data.lblod.info/id/bestuursorganen/7ccc7eefd703ea24cd27380a7cd1a820f2f260efff4835eda839d5e9e2aeda51",
  "http://data.lblod.info/id/bestuursorganen/4262ac2b81080930b7695451643dd08901d9873d9e6a6f3907bd6a81cb785da3",
  "http://data.lblod.info/id/bestuursorganen/e9b0392b504e9d038d0473425d072696ac5e9d56f6dabbb49e9c99905bf0560c",
  "http://data.lblod.info/id/bestuursorganen/23cd29bc0c30746b475e0e4679db9b208cfff79115b0248f8a06eceed1ddfff5",
  "http://data.lblod.info/id/bestuursorganen/4b8438450febfa199b07889df7d54bf17c6bf33e21823175ece7f63dd3297998",
  "http://data.lblod.info/id/bestuursorganen/720ec7879ee76f76914ce48b5a1fc289d7dba497b569dcf2099adb1c15ab32a6",
  "http://data.lblod.info/id/bestuursorganen/e67e63ef89cf142b57ead3dc97346f962c21fc1a822f8c5283998ed8b843d139",
  "http://data.lblod.info/id/bestuursorganen/50d1d0a21ff767aa596a51f5f06dab7119967bed535b6d55870e96686e5f51d3",
  "http://data.lblod.info/id/bestuursorganen/5fa47709eb3f805d43fdc77d76545333dc1d77a251826c19266418d06b34aad4",
  "http://data.lblod.info/id/bestuursorganen/6454b413d79fbc473c40d301fd7026f982b2a84ecd01317d6f6c70a9d3e897cc",
  "http://data.lblod.info/id/bestuursorganen/3268cdfb21f4bd612cf3e25f643b0ab70e35320742680a2d33e5d69f1dac1079",
  "http://data.lblod.info/id/bestuursorganen/e13fe60f9d6ef8a182520c4d07a93474f3249985fcd772b928ff9dc1cd12e7d9",
  "http://data.lblod.info/id/bestuursorganen/c8d2ead9251f8a32c464683798e48530756dccf791886858b23808918f7059df",
  "http://data.lblod.info/id/bestuursorganen/92a6a8b07fd4a88aa1568d7ed9e5fe84f26997019b5c3c4f32f32fde565cdff5",
  "http://data.lblod.info/id/bestuursorganen/61b74e507df1f45656ac5bde30d7a27f6b6b35cfcc164ee405372a3a4fbec664",
  "http://data.lblod.info/id/bestuursorganen/7333531164c8a32d4ddcc48c65c115c278479f971d3b9e96267a632e2a3e374c",
  "http://data.lblod.info/id/bestuursorganen/6408c72281ba9ba84ec09429cc9e6b8fecfb369b1c5200652d6485e38d352291",
  "http://data.lblod.info/id/bestuursorganen/904fab4ff586623d4613889cc7ae97a545aeec57c8693caecf75dbb6fc3504e1",
  "http://data.lblod.info/id/bestuursorganen/9bff3b566457693b41ddb994fb82c969e2a6e6322d6433e80063ffcac1e7f51b",
  "http://data.lblod.info/id/bestuursorganen/268f262aa3e397792dd319fba7414d185bdc105a0a0fd573a07ccf6557167206",
  "http://data.lblod.info/id/bestuursorganen/9b300d986f6049f2c2caedb9c0a94d517865d033729a2a7b280558c3f07c5df6",
  "http://data.lblod.info/id/bestuursorganen/a2a80d96328161eab7e03bcacaabf70f32c9d691cd9c37131120081f1728cf3a",
  "http://data.lblod.info/id/bestuursorganen/e9cb5b42b92d229005d55647f84652c76b3cdcc5f49cfff251cf2a6982ac64ee",
  "http://data.lblod.info/id/bestuursorganen/9f756848f80e8cfc3ec8b38c5b40ebfa86bc93c075b1157d7de6005da17db7ce",
  "http://data.lblod.info/id/bestuursorganen/c5a37d00ae7df614f4622b4b943c9f5dc7b9c4f3a54b3cf75b43a371868a39bb",
  "http://data.lblod.info/id/bestuursorganen/2cb71c14657eba8ac04f1143aae682209a6453156f29bb65164a6a864b5b013e",
  "http://data.lblod.info/id/bestuursorganen/0244800799baae6958a9a7ef2a6fef3b1541fc9e23edea7eb1b83b0ebcd1c843",
  "http://data.lblod.info/id/bestuursorganen/41d17a129d5b04b22e2157a46ab649cc40abc0f2e2d3e0db5538298f1e48e9c7",
  "http://data.lblod.info/id/bestuursorganen/5810d67e-0f46-48a6-a796-ffe899574d67",
  "http://data.lblod.info/id/bestuursorganen/a3f31176ec85c230f8553cf209ea5dc6047397c30622ee4dbcbf0714576ef7fe"
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
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000011>.
}
WHERE {
  VALUES ?orgaanInTijd {
    REPLACEVALUES
  }
  ?zitting a besluit:Zitting.
  ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.

  {
    {
    ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
    } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
    } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / mandaat:isTijdspecialisatieVan / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
    }
  }

  ?zitting (prov:startedAtTime | besluit:geplandeStart) ?date.
  FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
  ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
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
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit ext:title ?title.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/7b038cc40bba10bec833ecfe6f15bc7a>.
}
WHERE {
 VALUES ?orgaanInTijd {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.

 {
   {
    ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / mandaat:isTijdspecialisatieVan / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   }
 }

 ?zitting (prov:startedAtTime | besluit:geplandeStart) ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
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
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000012>.
}
WHERE {
 VALUES ?orgaanInTijd {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.

 {
   {
    ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / mandaat:isTijdspecialisatieVan / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   }
 }

 ?zitting (prov:startedAtTime | besluit:geplandeStart) ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
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
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000014>, <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/59a90e03-4f22-4bb9-8c91-132618db4b38> .
}
WHERE {
 VALUES ?orgaanInTijd {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.

 {
   {
    ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / mandaat:isTijdspecialisatieVan / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   }
 }

 ?zitting (prov:startedAtTime | besluit:geplandeStart) ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
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
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000019>.
}
WHERE {
 VALUES ?orgaanInTijd {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.

 {
   {
    ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / mandaat:isTijdspecialisatieVan / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   }
 }

 ?zitting (prov:startedAtTime | besluit:geplandeStart) ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 FILTER(CONTAINS(LCASE(?title), "leden"))
 FILTER(CONTAINS(LCASE(?title), "kie"))
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
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e00001a>.
}
WHERE {
 VALUES ?orgaanInTijd {
   REPLACEVALUES
 }
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.

 {
   {
    ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   } UNION {
    ?zitting (<http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor) / mandaat:isTijdspecialisatieVan / ^mandaat:isTijdspecialisatieVan ?orgaanInTijd .
   }
 }

 ?zitting (prov:startedAtTime | besluit:geplandeStart) ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?besluit <http://data.europa.eu/eli/ontology#title> | ( ^prov:generated / dct:subject / dct:title )  ?title.
 FILTER(CONTAINS(LCASE(?title), "voorzitter"))
 FILTER(CONTAINS(LCASE(?title), "kie"))
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
