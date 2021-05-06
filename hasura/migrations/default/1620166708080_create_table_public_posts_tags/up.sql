CREATE TABLE "public"."posts_tags" ("post_id" integer NOT NULL, "tag_id" integer NOT NULL, PRIMARY KEY ("post_id","tag_id") , FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id") ON UPDATE restrict ON DELETE restrict);