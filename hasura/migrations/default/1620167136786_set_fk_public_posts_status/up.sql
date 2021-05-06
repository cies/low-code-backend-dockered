alter table "public"."posts"
  add constraint "posts_status_fkey"
  foreign key ("status")
  references "public"."post_status"
  ("value") on update restrict on delete restrict;
