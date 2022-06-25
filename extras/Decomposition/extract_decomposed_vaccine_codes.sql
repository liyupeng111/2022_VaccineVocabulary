select vacc_id,
vacc_name,
vacc_vocab,
case 
when p6~ 'meningococcal' and p1~ 'diphtheria' then NULL 
when p6~ 'pneumococcal' and p1~ 'diphtheria' then NULL 
else p1 end as p1,
case when p6~ 'meningococcal' and p2~ 'tetanus' then NULL else p2 end as p2,
p3,
p4,
p5,
p6,
case 
when m6~ 'meningococcal' and m1~ 'diphtheria' then NULL 
when m6~ 'pneumococcal' and m1~ 'diphtheria' then NULL 
else m1 end as m1,
case when m6~ 'meningococcal' and m2~ 'tetanus' then NULL else m2 end as m2,
m3,
m4,
m5,
m6
from (
select concept_id as vacc_id, concept_synonym_name as vacc_name, vocabulary_id as vacc_vocab,
 case 
 when lower(concept_synonym_name) ~ 'diptheria|diphtheria' then 'diphtheria'
 when lower(concept_synonym_name) ~ 'tdp|dtp|dtap' then 'diphtheria'
 when lower(concept_synonym_name) ~ 'dt |td ' then 'diphtheria'
 when lower(concept_synonym_name) ~ 'mmrv' then 'measles'
 when lower(concept_synonym_name) ~ 'mmr' then 'measles'
 when lower(concept_synonym_name) ~ 'measles' then 'measles'
 when lower(concept_synonym_name) ~ 'hepatitis a|hep a' then 'hepatitis a'
 when lower(concept_synonym_name) ~ 'rabies' then 'rabies'
 when lower(concept_synonym_name) ~ 'rotavirus' then 'rotavirus'
 when lower(concept_synonym_name) ~ 'papilloma|hpv' then 'human papilomavirus'
 when lower(concept_synonym_name) ~ 'covid|coronavirus' then 'covid-19'
 when lower(concept_synonym_name) ~ 'typhoid|salmonella typhi' then 'typhoid'
 when lower(concept_synonym_name) ~ 'plague' then 'plague'
 when lower(concept_synonym_name) ~ 'anthrax' then 'anthrax'
 when lower(concept_synonym_name) ~ 'cholera' then 'cholera'
 end as p1,
 case 
 when lower(concept_synonym_name) ~ 'tdp|dtp|dtap' then 'tetanus'
 when lower(concept_synonym_name) ~ 'dt |td ' then 'tetanus'
 when lower(concept_synonym_name) ~ 'mmrv' then 'rubella'
 when lower(concept_synonym_name) ~ 'mmr' then 'rubella'
 when lower(concept_synonym_name) ~ 'rubella' then 'rubella'
 when lower(concept_synonym_name) ~ 'tetanus' then 'tetanus' 
 end as p2 ,
 case
 when lower(concept_synonym_name) ~ 'mumps' then 'mumps' 
 when lower(concept_synonym_name) ~ 'tdp|dtp|dtap' then 'pertussis'
 when lower(concept_synonym_name) ~ 'mmrv' then 'mumps'
 when lower(concept_synonym_name) ~ 'mmr' then 'mumps'
 when lower(concept_synonym_name) ~ 'pertussis' then 'pertussis'
 end as p3, 
 case 
 when lower(concept_synonym_name) ~ 'mmrv' then 'varicella'
 when lower(concept_synonym_name) ~ 'varicella|zoster|shingrix' then 'varicella'
 when lower(concept_synonym_name) ~ 'polio' then 'poliovirus'
 end as p4,
 case 
 when lower(concept_synonym_name) ~ 'hepatitis b|hep b' then 'hepatitis b'
 end as p5,
 case 
 when lower(concept_synonym_name) ~ 'haemophilus|hib |hibtiter' then 'haemophilus influenza'
 when lower(concept_synonym_name) ~ 'parainfluenza' then 'parainfluenza'
 when lower(concept_synonym_name) ~ 'influenza' then 'influenza'
 when lower(concept_synonym_name) ~ 'yellow fever' then 'yellow fever'
 when lower(concept_synonym_name) ~ 'japanese encephalitis|je\-vax' then 'japanese encephalitis'
 when lower(concept_synonym_name) ~ 'smallpox' then 'smallpox'
 when lower(concept_synonym_name) ~ 'adenovirus' then 'adenovirus'
 when lower(concept_synonym_name) ~ 'dengue' then 'dengue'
 when lower(concept_synonym_name) ~ 'hepatitis c' then 'hepatitis c'
 when lower(concept_synonym_name) ~ 'hepatitis e' then 'hepatitis e'
 when lower(concept_synonym_name) ~ 'venezuelan equine encephalitis' then 'Venezuelan equine encephalitis'
 when lower(concept_synonym_name) ~ 'tularemia' then 'tularemia'
 when lower(concept_synonym_name) ~ 'tick\-borne encephalitis' then 'tick-borne encephalitis'
 when lower(concept_synonym_name) ~ 'malaria' then 'malaria'
 when lower(concept_synonym_name) ~ 'Lyme' then 'Lyme'
 when lower(concept_synonym_name) ~ 'leprosy' then 'leprosy'
 when lower(concept_synonym_name) ~ 'leishmaniasis' then 'leishmaniasis'
 when lower(concept_synonym_name) ~ 'meningococcal|neisseria meningitidis|menquadfi'  then 'meningococcal'
 when lower(concept_synonym_name) ~ 'pneumococcal|streptococcus pneumoniae' then 'pneumococcal'
 end as p6,


 case 

 
 when lower(concept_synonym_name) ~ 'tdp|dtp' and lower(concept_synonym_name)~ 'toxoid' then 'diphtheria toxoid'
 when lower(concept_synonym_name) ~ 'tdap|dtap' and lower(concept_synonym_name)~ 'toxoid' then 'diphtheria toxoid'
 when lower(concept_synonym_name) ~ 'dt |td ' and lower(concept_synonym_name)~ 'toxoid' then 'diphtheria toxoid'

 when lower(concept_synonym_name) ~ 'diptheria|diphtheria' and lower(concept_synonym_name)~ 'toxoid' then 'diphtheria toxoid'
 when lower(concept_synonym_name) ~ 'diptheria|diphtheria' and lower(concept_synonym_name)~ 'antitoxin' then 'diphtheria antitoxin'
 when lower(concept_synonym_name) ~ 'measles'  and lower(concept_synonym_name) ~ 'live' then 'measles live'

 when lower(concept_synonym_name) ~ 'hepatitis a|hep a' and lower(concept_synonym_name) ~ 'live' then 'hepatitis a live'
 when lower(concept_synonym_name) ~ 'hepatitis a|hep a' and lower(concept_synonym_name) ~ 'inactiv' then 'hepatitis a inactivated'
 --when lower(concept_synonym_name) ~ 'rabies' then 'rabies'
 when lower(concept_synonym_name) ~ 'rotavirus' and lower(concept_synonym_name) ~ 'live' then 'rotavirus live'
 --when lower(concept_synonym_name) ~ 'papilloma|hpv' then 'human papilomavirus'
 when lower(concept_synonym_name) ~ 'covid' and lower(concept_synonym_name) ~ 'mrna' then 'covid-19 mRNA'
 when lower(concept_synonym_name) ~ 'covid' and lower(concept_synonym_name) ~ 'vector' then 'covid-19 vector'
 when lower(concept_synonym_name) ~ 'typhoid|salmonella typhi' and lower(concept_synonym_name) ~ 'live' then 'typhoid live'
 when lower(concept_synonym_name) ~ 'typhoid|salmonella typhi' and lower(concept_synonym_name) ~ 'conjugate' then 'typhoid conjugate'
 when lower(concept_synonym_name) ~ 'typhoid|salmonella typhi' and lower(concept_synonym_name) ~ 'acetone' then 'typhoid acetone-killed'
 when lower(concept_synonym_name) ~ 'typhoid|salmonella typhi' and lower(concept_synonym_name) ~ 'polysaccharide' then 'typhoid polysaccharide' 
 end as m1,
 case 
 when lower(concept_synonym_name) ~ 'rubella'  and lower(concept_synonym_name) ~ 'live' then 'rubella live'
 when lower(concept_synonym_name) ~ 'tetanus'  and lower(concept_synonym_name)~ 'toxoid' then 'tetanus toxoid' 
  when lower(concept_synonym_name) ~ 'tdp|dtp' and lower(concept_synonym_name)~ 'toxoid' then 'tetanus toxoid'
 when lower(concept_synonym_name) ~ 'tdap|dtap' and lower(concept_synonym_name)~ 'toxoid' then 'tetanus toxoid'
 when lower(concept_synonym_name) ~ 'dt |td ' and lower(concept_synonym_name)~ 'toxoid' then 'tetanus toxoid'
 end as m2 ,
 case
 when lower(concept_synonym_name) ~ 'mumps' and lower(concept_synonym_name) ~ 'live' then 'mumps live' 
 when lower(concept_synonym_name) ~ 'tdap|dtap|pertussis' and lower(concept_synonym_name)~ 'acellular' then 'acellular pertussis'
 when lower(concept_synonym_name) ~ 'tdap|dtap' then 'acellular pertussis'
 when lower(concept_synonym_name) ~ 'tdp|dtp' and lower(concept_synonym_name)~ 'toxoid' then 'whole cell pertussis'
 when lower(concept_synonym_name) ~ 'pertussis' and lower(concept_synonym_name)~ 'whole' then 'whole cell pertussis'
 end as m3, 
 case 
 when lower(concept_synonym_name) ~ 'varicella|zoster' and lower(concept_synonym_name)~ 'live' then 'varicella live'
 when lower(concept_synonym_name) ~ 'varicella|zoster' and lower(concept_synonym_name)~ 'recombinant' then 'varicella recombinant'
 when lower(concept_synonym_name) ~ 'polio' and lower(concept_synonym_name)~ 'live' then 'poliovirus live'
 when lower(concept_synonym_name) ~ 'polio' and lower(concept_synonym_name)~ 'inactivated' then 'poliovirus inactivated'
 end as m4,
 case 
 when lower(concept_synonym_name) ~ 'hepatitis b|hep b' and lower(concept_synonym_name)~ 'recombinant' then 'hepatitis b recombinant'
 end as m5,
 case 
 when lower(concept_synonym_name) ~ 'haemophilus|hib ' and lower(concept_synonym_name) ~ 'conjugate' then 'haemophilus influenza conjugate'
 when lower(concept_synonym_name) ~ 'influenza' and lower(concept_synonym_name)~ 'live' then 'influenza live'
 when lower(concept_synonym_name) ~ 'influenza' and lower(concept_synonym_name)~ 'recomb' then 'influenza recomb'
 --when lower(concept_synonym_name) ~ 'yellow fever' then 'yellow fever'
 --when lower(concept_synonym_name) ~ 'japanese encephalitis' then 'japanese encephalitis'
 --when lower(concept_synonym_name) ~ 'smallpox' then 'smallpox'
 when lower(concept_synonym_name) ~ 'adenovirus' and lower(concept_synonym_name)~ 'live' then 'adenovirus live'
 --when lower(concept_synonym_name) ~ 'dengue' then 'dengue'
 --when lower(concept_synonym_name) ~ 'hepatitis c' then 'hepatitis c'
 --when lower(concept_synonym_name) ~ 'hepatitis e' then 'hepatitis e'
 when lower(concept_synonym_name) ~ 'venezuelan equine encephalitis' and lower(concept_synonym_name)~ 'live' then 'Venezuelan equine encephalitis live'
 when lower(concept_synonym_name) ~ 'venezuelan equine encephalitis' and lower(concept_synonym_name)~ 'inactivated' then 'Venezuelan equine encephalitis inactivated'
 
 when lower(concept_synonym_name) ~ 'meningococcal|neisseria meningitidis' and lower(concept_synonym_name) ~ 'polysaccharide' then 'meningococcal polysaccharide'
 when lower(concept_synonym_name) ~ 'meningococcal|neisseria meningitidis' and lower(concept_synonym_name) ~ 'oligosaccharide' then 'meningococcal oligosaccharide'
 when lower(concept_synonym_name) ~ 'meningococcal|neisseria meningitidis' and lower(concept_synonym_name) ~ 'conjugate' then 'meningococcal conjugate'
 when lower(concept_synonym_name) ~ 'meningococcal|neisseria meningitidis' and lower(concept_synonym_name) ~ 'recombinant' then 'meningococcal recombinant'
  when lower(concept_synonym_name) ~ 'pneumococcal|streptococcus pneumoniae' and lower(concept_synonym_name) ~ 'polysaccharide' then 'pneumococcal polysaccharide'
 when lower(concept_synonym_name) ~ 'pneumococcal|streptococcus pneumoniae' and lower(concept_synonym_name) ~ 'conjugate' then 'pneumococcal conjugate'
 

 end as m6
from devv5.concept c
join devv5.concept_synonym cs using(concept_id)
where 
(
-- Influenza and Haemophilus influenza vaccines
lower(concept_synonym_name) ~ 'influenza|h3n2|h1n1|haemophilus|hib '
or
-- Diphteria, Pertussis, Tetanus and Polio vaccines 
lower(concept_synonym_name) ~ 'diphtheria|tetanus|pertussis|tdap|tdp |poliovirus|polio |poliomyelitis'
or
-- Measles, Mumps, Rubella, Varicella and Zoster vaccines 
lower(concept_synonym_name) ~ 'measles|rubella|mumps|varicella|mmr|zoster'
or 
-- Pneumococcal, Meningococcal and Encephalitis vaccines 
lower(concept_synonym_name) ~ 'pneumococcal|meningococcal|encephalitis|streptococcus pneumoniae|neisseria meningitidis'
or
-- BCG, Typhoid, Botulinum, Cholera and Rabies vaccines
lower(concept_synonym_name) ~ 'rabies|typhoid|salmonella typhi'
or
-- Herpes group vaccine, HPV and Hepatitis 
lower(concept_synonym_name) ~ 'hepatitis|hep a|hep b|hep c|herpes|papilloma|hpv|hantavirus|cytomegalovirus'
or
-- other vaccines
lower(concept_synonym_name) ~ 'vaccine|adenovirus|anthrax|bacillus anthracis|junin|leishmaniasis|lyme |malaria|yellow fever|tularemia|yersinia pestis|brucella melitensis|rickettsia prowazekii|brucella abortus' -- discuss last 4 topics
)
-- filter junk concepts
and lower(concept_synonym_name) !~ 'not\sreceive|bacillus calmette\-guerin|bcg|did not|respiratory vaccine|heparin|imm glob|immune|immuno|topical oil|neurotox|sinusin|neti wash flu|allantoin|upper respiratory staph|pleo san brucel|archangelica|pallet|pellet|hp\_c|guna\-tf|homocord|homochord|homeopathic|condylomata|hp\_x|remedy|influenzinum|thuja|biotox|echinacea|arnica|arsenicum|antimony|pharyngitis|glucose|panel|factor|aconitum|nipple|acyclovir|rosmarinus|extract|moraxella|geissospermum|nosodes|hyaluronate|skin test|travel|destruction|antibody panel|resection|screen'
-- defining domain 
and domain_id in ('Drug','Procedure')
and vocabulary_id in ( 'RxNorm','NDC', 'ICD9Proc', 'ICD10PCS', 'CPT4', 'HCPCS', 'CVX')
and concept_name !~ 'influenza'
--filter some tests
and concept_id not in (725027,709850,709851,709852)
) a 
where p1 is not null or
p2 is not null or
p3 is not null or
p4 is not null or
p5 is not null or
p6 is not null or
m1 is not null or
m2 is not null or
m3 is not null or
m4 is not null or
m5 is not null or
m6 is not null
;
