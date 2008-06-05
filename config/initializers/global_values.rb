TIMEZONES = [
  ['GMT-12:00', '-720'],
  ['GMT-11:00', '-660'],
  ['GMT-10:00', '-600'],
  ['GMT-9:00',  '-540'],
  ['GMT-8:00',  '-480'],
  ['GMT-7:00',  '-420'],
  ['GMT-6:00',  '-360'],
  ['GMT-5:00',  '-300'],
  ['GMT-4:00',  '-240'],
  ['GMT-3:30',  '-210'],
  ['GMT-3:00',  '-180'],
  ['GMT-2:00',  '-120'],
  ['GMT-1:00',  '-60'],
  ['GMT',       '0'],
  ['GMT+1:00',  '60'],
  ['GMT+2:00',  '120'],
  ['GMT+3:00',  '180'],
  ['GMT+3:30',  '210'],
  ['GMT+4:00',  '240'],
  ['GMT+4:30',  '270'],
  ['GMT+5:00',  '300'],
  ['GMT+5:30',  '330'],
  ['GMT+5:45',  '345'],
  ['GMT+6:00',  '360'],
  ['GMT+7:00',  '420'],
  ['GMT+8:00',  '480'],
  ['GMT+9:00',  '540'],
  ['GMT+9:30',  '570'],
  ['GMT+10:00', '600'],
  ['GMT+11:00', '660'],
  ['GMT+12:00', '720'],
  ['GMT+13:00', '780']
]

SELECT_STONE = Array[]
SELECT_LBS = Array[]
SELECT_KG = Array[]

0.upto(50) {|s| SELECT_STONE << [s.to_s, s.to_s]}
0.upto(13) {|l| SELECT_LBS << [l.to_s, l.to_s]}
0.upto(400) {|k| SELECT_KG << [k.to_s, k.to_s]}

SELECT_INCHES = Array[]
SELECT_CM = Array []
SELECT_QUANTITY = Array[]

1.upto(112) {|i| SELECT_INCHES << [i.to_s, i.to_s]}
1.upto(300) {|c| SELECT_CM << [c.to_s, c.to_s]}
1.upto(50)  {|q| SELECT_QUANTITY << [q.to_s, q.to_s]}
