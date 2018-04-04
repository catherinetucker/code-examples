with s as (select a.*
,b.countunknown
,c.count499 cs_499
,d.count500 cs_500_550
,e.count550 cs_550_600
,f.count600 cs_600_650
,g.count650 cs_650_700
,h.count700 cs_700_750
,i.count750 cs_750_800
,j.count800 cs800_
from ee.zipcodetoutilitylookup a
join ee.mdzctapop md 
full outer join ee.allzipcreditscores b on a.vb_tsmart_zip=b.zipunknown
full outer join ee.allzipcreditscores c on a.vb_tsmart_zip=c.zip499
full outer join ee.allzipcreditscores d on a.vb_tsmart_zip=d.zip500
full outer join ee.allzipcreditscores e on a.vb_tsmart_zip=e.zip550
full outer join ee.allzipcreditscores f on a.vb_tsmart_zip=f.zip600
full outer join ee.allzipcreditscores g on a.vb_tsmart_zip=g.zip650
full outer join ee.allzipcreditscores h on a.vb_tsmart_zip=h.zip700
full outer join ee.allzipcreditscores i on a.vb_tsmart_zip=i.zip750
full outer join ee.allzipcreditscores j on a.vb_tsmart_zip=j.zip800
where a.iutilityid in ('121','16','41','119')
),


i as (select *
,isnull(cs_499,0)+isnull(cs_500_550,0)+isnull(cs_550_600,0)+isnull(cs_600_650,0)+isnull(cs_650_700,0)+isnull(cs_700_750,0)+isnull(cs_750_800,0)+isnull(cs800_,0) as totalpop_cs
from s),

j as (select vb_tsmart_zip
,u.iutilityid
,total_pop
,(sum(cs_499::float))/(sum(totalpop_cs::float)) as cs_499
,(sum(cs_500_550::float))/(sum(totalpop_cs::float)) cs_500
,(sum(cs_550_600::float))/(sum(totalpop_cs::float)) cs_550i
,(sum(cs_600_650::float))/(sum(totalpop_cs::float)) cs_600
,(sum(cs_650_700::float))/(sum(totalpop_cs::float)) cs_650
,(sum(cs_700_750::float))/(sum(totalpop_cs::float)) cs_700
,(sum(cs_750_800::float))/(sum(totalpop_cs::float)) cs_750
,(sum(cs800_::float))/(sum(totalpop_cs::float)) as cs_800
,(sum(cs_750_800::float)+sum(cs800_::float))/(sum(totalpop_cs::float)) as cs_gt750
,(sum(cs_700_750::float)+sum(cs_750_800::float)+sum(cs800_::float))/(sum(totalpop_cs::float)) as cs_gt700
,(sum(cs_700_750::float)+sum(cs_750_800::float)+sum(cs800_::float)+sum(cs_650_700::float))/(sum(totalpop_cs::float)) as cs_gt650
from i
join ee.utilities u on i.iutilityid=u.iutilityid
where total>300 and totalpop_cs>300
group by 1,2,3)
