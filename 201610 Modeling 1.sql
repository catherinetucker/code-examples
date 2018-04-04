--40 K+ with downsampling
--7,573 meet our criteria


--Naming Convention
--dv/ts for dependent variable or training set
--monthly release date 2016/10 year/month
--versioning with documentation about attributes 

drop table if exists modeling.modeling_dv_201610_1;
create table modeling.modeling_dv_201610_1 distkey(voterbase_id) sortkey(voterbase_id) as (
(select voterbase_id
, signupdv 
from (
        select distinct ts.voterbase_id as voterbase_id
        ,case when ((dtstartdt >= '2015-11-01') AND (datediff(d, dtstartdt, dtservicedropdt) >= 60 OR (dtservicedropdt is null))) then 1 else 0 end as signupdv
        from ee.mailmatchback m
        join modeling.training_crosswalk tc on tc.mailing=m.mailing and tc.list=m.list and tc.package=m.package
        join 
                (
                select * 
                from 
                        (select source_id
                        , matched_id
                        , row_number() over (partition by matched_id order by score desc, source_id desc) 
                        from modeling.mail_model_test_prematch_20160902
                        ) where row_number = 1
                ) s on s.source_id = m.rowid
        join tsmart_base.modeling_commercial ts on s.matched_id = ts.voterbase_id      
        where s.matched_id is not null 
                and ts.voterbase_id is not null 
                and s.matched_id not in (select voterbase_id from mailings.v_suppression where voterbase_id is not null and suppressiongroup!='Active Accounts')
                and ts.coalesced_commercial_age <75
                and m.mailing in ('June 2016 RRD Mailing', 'March 2016 RRD Mailing', 'May 2016 RRD Mailing', 'November 2015 RRD Mailing')
                and tc.include_in_model=true
                and m.imailMatchBackStatusID=2
                 
        )
where signupdv = 1
order by random()
)

UNION ALL

(select voterbase_id
, signupdv 
from 
        (select distinct ts.voterbase_id as voterbase_id
        ,case when ((dtstartdt >= '2015-11-01') AND (datediff(d, dtstartdt, dtservicedropdt) >= 60 OR (dtservicedropdt is null))) then 1 else 0 end as signupdv
        from ee.mailmatchback m
        join modeling.training_crosswalk tc on tc.mailing=m.mailing and tc.list=m.list and tc.package=m.package
        join 
                (
                select * 
                from 
                        (select source_id
                        , matched_id
                        , row_number() over (partition by matched_id order by score desc, source_id desc) 
                        from modeling.mail_model_test_prematch_20160902
                        ) where row_number = 1
                ) s on s.source_id = m.rowid
        join tsmart_base.modeling_commercial ts on s.matched_id = ts.voterbase_id      
        where s.matched_id is not null 
                and ts.voterbase_id is not null 
                and s.matched_id not in (select voterbase_id from mailings.v_suppression where voterbase_id is not null and suppressiongroup!='Active Accounts')
                and ts.coalesced_commercial_age <75
                and m.mailing in ('June 2016 RRD Mailing', 'March 2016 RRD Mailing', 'May 2016 RRD Mailing', 'November 2015 RRD Mailing')
                and tc.include_in_model=true
                and s.matched_id in (select voterbase_id from civis_scores.ee_mail_scores_20160512 where mail_percentile<81)
                and m.imailMatchBackStatusID is null
	)
where signupdv = 0
order by random()
limit (9088)
)

UNION ALL

(select voterbase_id
, signupdv 
from 
        (select distinct ts.voterbase_id as voterbase_id
        ,case when ((dtstartdt >= '2015-11-01') AND (datediff(d, dtstartdt, dtservicedropdt) >= 60 OR (dtservicedropdt is null))) then 1 else 0 end as signupdv
        from ee.mailmatchback m
        join modeling.training_crosswalk tc on tc.mailing=m.mailing and tc.list=m.list and tc.package=m.package
        join 
                (
                select * 
                from 
                        (select source_id
                        , matched_id
                        , row_number() over (partition by matched_id order by score desc, source_id desc) 
                        from modeling.mail_model_test_prematch_20160902
                        ) where row_number = 1
                ) s on s.source_id = m.rowid
        join tsmart_base.modeling_commercial ts on s.matched_id = ts.voterbase_id      
        where s.matched_id is not null 
                and ts.voterbase_id is not null 
                and s.matched_id not in (select voterbase_id from mailings.v_suppression where voterbase_id is not null and suppressiongroup!='Active Accounts')
                and ts.coalesced_commercial_age <75
                and m.mailing in ('June 2016 RRD Mailing', 'March 2016 RRD Mailing', 'May 2016 RRD Mailing', 'November 2015 RRD Mailing')
                and tc.include_in_model=true
                and s.matched_id in (select voterbase_id from civis_scores.ee_mail_scores_20160512 where mail_percentile>=81)
                and m.imailMatchBackStatusID is null
	)
where signupdv = 0
order by random()
limit (21204)
));


create table modeling.modeling_ts_201610_1 as (
--explain
select m.*
,u.*
,f.frequency
--dummy have we ever mailed someone prior to that date

--Monday, I need to figure out how to do the duration stuff and then get the jobs running. 
,s.signupdv
from modeling.modeling_dv_201610_1 s
join tsmart_base.modeling_commercial m on s.voterbase_id = m.voterbase_id
left join ee.utilitiesincluded_acs_5yr u on u.blockgroupid = left(m.tsmart_census_block_fips,12)
left join mailings.v_frequency f on f.voterbaseid = s.voterbaseid
where m.voterbase_id is not null and s.voterbase_id is not null);
