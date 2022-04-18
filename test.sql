CREATE EXTENSION zombodb;

CREATE TABLE analyzers_test (
  pkey       serial8 NOT NULL PRIMARY KEY,
  arabic     zdb.arabic,
  armenian   zdb.armenian,
--  basque     zdb.basque,  -- no texts of this language
--  brazilian  zdb.brazilian,  -- no texts of this language
  bulgarian  zdb.bulgarian,
  catalan    zdb.catalan,
  chinese    zdb.chinese,
  cjk        zdb.cjk,
  czech      zdb.czech,
  danish     zdb.danish,
  dutch      zdb.dutch,
  english    zdb.english,
  finnish    zdb.finnish,
  french     zdb.french,
--  galician   zdb.galician, -- no texts of this language
  german     zdb.german,
--  greek      zdb.greek, -- no texts of this language
  hindi      zdb.hindi,
  hungarian  zdb.hungarian,
  indonesian zdb.indonesian,
  irish      zdb.irish,
  italian    zdb.italian,
--  latvian    zdb.latvian, -- no texts of this language
  norwegian  zdb.norwegian,
  persian    zdb.persian,
  portuguese zdb.portuguese,
  romanian   zdb.romanian,
  russian    zdb.russian,
--  sorani     zdb.sorani, -- no texts of this language
  spanish    zdb.spanish,
  swedish    zdb.swedish,
  turkish    zdb.turkish,
  thai       zdb.thai,
  standard   zdb.zdb_standard,
  whitespace zdb.whitespace
);


INSERT INTO analyzers_test VALUES (
  DEFAULT,
  'هذا اختبار'
  , 'սա փորձություն է'
  , 'това е тест'
  , 'Això és un examen'
  , '这是一个测试'
  , 'これはテストです' -- cjk (japanese)
  , 'toto je test'
  , 'dette er en test'
  , 'dit is een test'
  , 'this is a test' -- english
  , 'Tämä on koe'
  , 'c''est un test'
  , 'das ist ein Test' -- german
  , 'यह एक परीक्षण है' -- hindi
  , 'ez egy teszt'
  , 'ini adalah sebuah ujian'
  , 'tá sé seo le tástáil'
  , 'questa è una prova'
  , 'dette er en test' -- norwegian
  , 'این یک امتحان است' -- persian
  , 'isso é um teste'
  , 'acesta este un test'
  , 'Это тест' -- russian
  , 'esto es un exámen'
  , 'detta är ett prov'
  , 'bu bir test' -- turkish
  , 'นี่คือการทดสอบ'
  , 'this is a test' -- zdb_standard
  , 'this is a test' -- whitespace
  );

INSERT INTO analyzers_test VALUES (
  default
  , NULL
  , NULL
  , NULL -- bg
  , NULL
  , NULL
  , NULL -- cjk (japanese)
  , NULL
  , NULL
  , NULL
  , 'the quick brown fox jumped over the lazy dog' -- english
  , NULL
  , NULL
  , NULL -- german
  , NULL -- hindi
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL -- norwegian
  , null -- persian
  , NULL
  , NULL
  , NULL -- russian
  , NULL
  , NULL
  , NULL -- turkish
  , NULL
  , NULL -- zdb_standard
  , NULL -- whitespace
  );
 
 INSERT INTO analyzers_test VALUES (
  default
  , NULL
  , NULL
  , NULL -- bg
  , NULL
  , NULL
  , NULL -- cjk (japanese)
  , NULL
  , NULL
  , 'hier probeer ik wat nederlandse tekst neer te knallen, lopen, werken, zoeken, gaan, scholen, discos, verkennen'
  , null -- english
  , NULL
  , NULL
  , NULL -- german
  , NULL -- hindi
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL -- norwegian
  , null -- persian
  , NULL
  , NULL
  , NULL -- russian
  , NULL
  , NULL
  , NULL -- turkish
  , NULL
  , NULL -- zdb_standard
  , NULL -- whitespace
  );
 
  INSERT INTO analyzers_test VALUES (default, null , null , NULL , null , NULL, NULL, NULL, NULL, NULL
  , null, NULL, NULL, NULL, NULL, NULl, NULL, NULL, NULl, NULL , null, NULL, NULL, NULL, NULL , NUll, NULL, NULL
  , NULL -- zdb_standard
  , 'hier probeer ik alleen wat nieuwe dingen om te kijken welke queries werken'  );
 
   INSERT INTO analyzers_test VALUES (default, null , null , NULL , null , NULL, NULL, NULL, NULL, NULL
  , null, NULL, NULL, NULL, NULL, NULl, NULL, NULL, NULl, NULL , null, NULL, NULL, NULL, NULL , NUll, NULL, NULL
  , 'hier probeer ik alleen wat nieuwe dingen om te kijken welke queries werken'
  , NULL -- whitespace
  );
 
CREATE INDEX idxanalyzers_test ON analyzers_test USING zombodb ((analyzers_test)) WITH (url='http://elasticsearch:9200/');;

SELECT
  attname,
  (SELECT count(*) > 0 FROM analyzers_test WHERE analyzers_test ==> term(attname, 'test')) found
FROM pgattribute
WHERE attrelid = 'analyzers_test'::regclass AND attnum >= 1 AND attname <> 'pkey'
ORDER BY attnum;

SELECT
  attname,
  q
FROM analyzers_test, (SELECT
                        attname,
                        (attname || ':' || ((SELECT row_to_json(analyzers_test)
                                             FROM analyzers_test) -> attname))::text q
                      FROM pg_attribute
                      WHERE attrelid = 'analyzers_test'::regclass AND attnum >= 1 AND attname <> 'pkey') x
WHERE analyzers_test ==> q
ORDER BY attname;

SELECT * FROM analyzers_test WHERE analyzers_test ==> 'dinge~4';




DROP TABLE analyzers_test;

