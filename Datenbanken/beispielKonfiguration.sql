PGDMP                          z        
   openremote    14.1    14.5 ?               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16384 
   openremote    DATABASE     ^   CREATE DATABASE openremote WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';
    DROP DATABASE openremote;
                postgres    false                       0    0 
   openremote    DATABASE PROPERTIES     G   ALTER DATABASE openremote SET search_path TO 'openremote', 'topology';
                     postgres    false                        2615    21145 
   openremote    SCHEMA        CREATE SCHEMA openremote;
    DROP SCHEMA openremote;
                postgres    false            ?           1255    22627    get_asset_tree_path(text)    FUNCTION     B  CREATE FUNCTION openremote.get_asset_tree_path(asset_id text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
begin
  return (with recursive ASSET_TREE(ID, PARENT_ID, PATH) as (
    select
      A1.ID,
      A1.PARENT_ID,
      array [text(A1.ID)]
    from ASSET A1
    where A1.ID = ASSET_ID
    union all
    select
      A2.ID,
      A2.PARENT_ID,
      array_append(AT.PATH, text(A2.ID))
    from ASSET A2, ASSET_TREE AT
    where A2.ID = AT.PARENT_ID and AT.PARENT_ID is not null
  ) select PATH
    from ASSET_TREE
    where PARENT_ID is null);
end;
$$;
 =   DROP FUNCTION openremote.get_asset_tree_path(asset_id text);
    
   openremote          postgres    false    8            ?           1255    22626    update_asset_parent_info()    FUNCTION     :  CREATE FUNCTION openremote.update_asset_parent_info() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    ppath ltree;
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.path = NEW.id::ltree;
    ELSEIF TG_OP = 'INSERT' OR OLD.parent_id IS NULL OR OLD.parent_id != NEW.parent_id THEN
        SELECT A.path || NEW.id::text INTO ppath FROM ASSET A WHERE id = NEW.parent_id;
        IF ppath IS NULL THEN
            RAISE EXCEPTION 'Invalid parent_id %', NEW.parent_id;
        END IF;
        NEW.path = ppath;
    END IF;
    RETURN NEW;
END;
$$;
 5   DROP FUNCTION openremote.update_asset_parent_info();
    
   openremote          postgres    false    8            B           1259    22543    asset    TABLE     ?  CREATE TABLE openremote.asset (
    id character varying(22) NOT NULL,
    attributes jsonb,
    created_on timestamp with time zone NOT NULL,
    name character varying(1023) NOT NULL,
    parent_id character varying(22),
    path openremote.ltree,
    realm character varying(255) NOT NULL,
    type character varying(500) NOT NULL,
    access_public_read boolean NOT NULL,
    version bigint NOT NULL,
    CONSTRAINT asset_check CHECK (((id)::text <> (parent_id)::text))
);
    DROP TABLE openremote.asset;
    
   openremote         heap    postgres    false    8    8    8    8    8    8    8    8    8    8    8            C           1259    22551    asset_datapoint    TABLE     ?   CREATE TABLE openremote.asset_datapoint (
    "timestamp" timestamp without time zone NOT NULL,
    entity_id character varying(22) NOT NULL,
    attribute_name character varying(255) NOT NULL,
    value jsonb NOT NULL
);
 '   DROP TABLE openremote.asset_datapoint;
    
   openremote         heap    postgres    false    8            J           1259    22602    asset_predicted_datapoint    TABLE     ?   CREATE TABLE openremote.asset_predicted_datapoint (
    "timestamp" timestamp without time zone NOT NULL,
    entity_id character varying(36) NOT NULL,
    attribute_name character varying(255) NOT NULL,
    value jsonb NOT NULL
);
 1   DROP TABLE openremote.asset_predicted_datapoint;
    
   openremote         heap    postgres    false    8            E           1259    22565    asset_ruleset    TABLE     ?  CREATE TABLE openremote.asset_ruleset (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    enabled boolean NOT NULL,
    last_modified timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    rules text NOT NULL,
    rules_lang character varying(255) DEFAULT 'GROOVY'::character varying NOT NULL,
    version bigint NOT NULL,
    asset_id character(22) NOT NULL,
    access_public_read boolean DEFAULT false NOT NULL,
    meta jsonb
);
 %   DROP TABLE openremote.asset_ruleset;
    
   openremote         heap    postgres    false    8            M           1259    22676 	   dashboard    TABLE     ?  CREATE TABLE openremote.dashboard (
    id character varying(22) NOT NULL,
    created_on timestamp with time zone NOT NULL,
    realm character varying(255) NOT NULL,
    version bigint NOT NULL,
    owner_id character varying(255) NOT NULL,
    view_access bigint NOT NULL,
    edit_access bigint NOT NULL,
    display_name character varying(255) NOT NULL,
    template jsonb NOT NULL
);
 !   DROP TABLE openremote.dashboard;
    
   openremote         heap    postgres    false    8            5           1259    21146    flyway_schema_history    TABLE     ?  CREATE TABLE openremote.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);
 -   DROP TABLE openremote.flyway_schema_history;
    
   openremote         heap    postgres    false    8            K           1259    22609    gateway_connection    TABLE     h  CREATE TABLE openremote.gateway_connection (
    local_realm character varying(255) NOT NULL,
    realm character varying(255) NOT NULL,
    host character varying(255) NOT NULL,
    port bigint,
    client_id character varying(36) NOT NULL,
    client_secret character varying(36) NOT NULL,
    secured boolean,
    disabled boolean DEFAULT false NOT NULL
);
 *   DROP TABLE openremote.gateway_connection;
    
   openremote         heap    postgres    false    8            D           1259    22558    global_ruleset    TABLE     h  CREATE TABLE openremote.global_ruleset (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    enabled boolean NOT NULL,
    last_modified timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    rules text NOT NULL,
    rules_lang character varying(255) NOT NULL,
    version bigint NOT NULL,
    meta jsonb
);
 &   DROP TABLE openremote.global_ruleset;
    
   openremote         heap    postgres    false    8            H           1259    22588    notification    TABLE       CREATE TABLE openremote.notification (
    id bigint NOT NULL,
    name character varying(255),
    type character varying(50) NOT NULL,
    target character varying(50) NOT NULL,
    target_id character varying(255) NOT NULL,
    source character varying(50) NOT NULL,
    source_id character varying(43),
    message jsonb,
    error character varying(4096),
    sent_on timestamp with time zone NOT NULL,
    delivered_on timestamp with time zone,
    acknowledged_on timestamp with time zone,
    acknowledgement character varying(255)
);
 $   DROP TABLE openremote.notification;
    
   openremote         heap    postgres    false    8            A           1259    22542    openremote_sequence    SEQUENCE     ?   CREATE SEQUENCE openremote.openremote_sequence
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE openremote.openremote_sequence;
    
   openremote          postgres    false    8            L           1259    22617    provisioning_config    TABLE     ?  CREATE TABLE openremote.provisioning_config (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    last_modified timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(100) NOT NULL,
    roles character varying(255)[],
    realm character varying(255) NOT NULL,
    asset_template text,
    restricted_user boolean DEFAULT false NOT NULL,
    data jsonb
);
 +   DROP TABLE openremote.provisioning_config;
    
   openremote         heap    postgres    false    8            F           1259    22574    realm_ruleset    TABLE     ?  CREATE TABLE openremote.realm_ruleset (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    enabled boolean NOT NULL,
    last_modified timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    rules text NOT NULL,
    rules_lang character varying(255) DEFAULT 'GROOVY'::character varying NOT NULL,
    version bigint NOT NULL,
    realm character varying(255) NOT NULL,
    access_public_read boolean DEFAULT false NOT NULL,
    meta jsonb
);
 %   DROP TABLE openremote.realm_ruleset;
    
   openremote         heap    postgres    false    8            I           1259    22595    syslog_event    TABLE       CREATE TABLE openremote.syslog_event (
    id bigint NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    category character varying(255) NOT NULL,
    level integer NOT NULL,
    message character varying(131072),
    subcategory character varying(1024)
);
 $   DROP TABLE openremote.syslog_event;
    
   openremote         heap    postgres    false    8            G           1259    22583    user_asset_link    TABLE     ?   CREATE TABLE openremote.user_asset_link (
    asset_id character(22) NOT NULL,
    realm character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL,
    created_on timestamp with time zone NOT NULL
);
 '   DROP TABLE openremote.user_asset_link;
    
   openremote         heap    postgres    false    8            ?          0    22543    asset 
   TABLE DATA           ?   COPY openremote.asset (id, attributes, created_on, name, parent_id, path, realm, type, access_public_read, version) FROM stdin;
 
   openremote          postgres    false    322   ?k       ?          0    22551    asset_datapoint 
   TABLE DATA           \   COPY openremote.asset_datapoint ("timestamp", entity_id, attribute_name, value) FROM stdin;
 
   openremote          postgres    false    323   ?o       ?          0    22602    asset_predicted_datapoint 
   TABLE DATA           f   COPY openremote.asset_predicted_datapoint ("timestamp", entity_id, attribute_name, value) FROM stdin;
 
   openremote          postgres    false    330   ?o       ?          0    22565    asset_ruleset 
   TABLE DATA           ?   COPY openremote.asset_ruleset (id, created_on, enabled, last_modified, name, rules, rules_lang, version, asset_id, access_public_read, meta) FROM stdin;
 
   openremote          postgres    false    325   ?o                  0    22676 	   dashboard 
   TABLE DATA           ?   COPY openremote.dashboard (id, created_on, realm, version, owner_id, view_access, edit_access, display_name, template) FROM stdin;
 
   openremote          postgres    false    333   ?o       ?          0    21146    flyway_schema_history 
   TABLE DATA           ?   COPY openremote.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
 
   openremote          postgres    false    309   r       ?          0    22609    gateway_connection 
   TABLE DATA           }   COPY openremote.gateway_connection (local_realm, realm, host, port, client_id, client_secret, secured, disabled) FROM stdin;
 
   openremote          postgres    false    331   s       ?          0    22558    global_ruleset 
   TABLE DATA           |   COPY openremote.global_ruleset (id, created_on, enabled, last_modified, name, rules, rules_lang, version, meta) FROM stdin;
 
   openremote          postgres    false    324   *s       ?          0    22588    notification 
   TABLE DATA           ?   COPY openremote.notification (id, name, type, target, target_id, source, source_id, message, error, sent_on, delivered_on, acknowledged_on, acknowledgement) FROM stdin;
 
   openremote          postgres    false    328   Gs       ?          0    22617    provisioning_config 
   TABLE DATA           ?   COPY openremote.provisioning_config (id, created_on, disabled, last_modified, name, type, roles, realm, asset_template, restricted_user, data) FROM stdin;
 
   openremote          postgres    false    332   ds       ?          0    22574    realm_ruleset 
   TABLE DATA           ?   COPY openremote.realm_ruleset (id, created_on, enabled, last_modified, name, rules, rules_lang, version, realm, access_public_read, meta) FROM stdin;
 
   openremote          postgres    false    326   ?s       /          0    21467    spatial_ref_sys 
   TABLE DATA           \   COPY openremote.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
 
   openremote          postgres    false    311   ?t       ?          0    22595    syslog_event 
   TABLE DATA           b   COPY openremote.syslog_event (id, "timestamp", category, level, message, subcategory) FROM stdin;
 
   openremote          postgres    false    329   u       ?          0    22583    user_asset_link 
   TABLE DATA           S   COPY openremote.user_asset_link (asset_id, realm, user_id, created_on) FROM stdin;
 
   openremote          postgres    false    327   ?x                  0    0    openremote_sequence    SEQUENCE SET     H   SELECT pg_catalog.setval('openremote.openremote_sequence', 1030, true);
       
   openremote          postgres    false    321            D           2606    22557 $   asset_datapoint asset_datapoint_pkey 
   CONSTRAINT     ?   ALTER TABLE ONLY openremote.asset_datapoint
    ADD CONSTRAINT asset_datapoint_pkey PRIMARY KEY ("timestamp", entity_id, attribute_name);
 R   ALTER TABLE ONLY openremote.asset_datapoint DROP CONSTRAINT asset_datapoint_pkey;
    
   openremote            postgres    false    323    323    323            @           2606    22550    asset asset_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY openremote.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY openremote.asset DROP CONSTRAINT asset_pkey;
    
   openremote            postgres    false    322            R           2606    22608 8   asset_predicted_datapoint asset_predicted_datapoint_pkey 
   CONSTRAINT     ?   ALTER TABLE ONLY openremote.asset_predicted_datapoint
    ADD CONSTRAINT asset_predicted_datapoint_pkey PRIMARY KEY ("timestamp", entity_id, attribute_name);
 f   ALTER TABLE ONLY openremote.asset_predicted_datapoint DROP CONSTRAINT asset_predicted_datapoint_pkey;
    
   openremote            postgres    false    330    330    330            H           2606    22573     asset_ruleset asset_ruleset_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY openremote.asset_ruleset
    ADD CONSTRAINT asset_ruleset_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY openremote.asset_ruleset DROP CONSTRAINT asset_ruleset_pkey;
    
   openremote            postgres    false    325            X           2606    22682    dashboard dashboard_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY openremote.dashboard
    ADD CONSTRAINT dashboard_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY openremote.dashboard DROP CONSTRAINT dashboard_pkey;
    
   openremote            postgres    false    333            ;           2606    21153 .   flyway_schema_history flyway_schema_history_pk 
   CONSTRAINT     |   ALTER TABLE ONLY openremote.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);
 \   ALTER TABLE ONLY openremote.flyway_schema_history DROP CONSTRAINT flyway_schema_history_pk;
    
   openremote            postgres    false    309            T           2606    22616 *   gateway_connection gateway_connection_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY openremote.gateway_connection
    ADD CONSTRAINT gateway_connection_pkey PRIMARY KEY (local_realm);
 X   ALTER TABLE ONLY openremote.gateway_connection DROP CONSTRAINT gateway_connection_pkey;
    
   openremote            postgres    false    331            F           2606    22564 "   global_ruleset global_ruleset_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY openremote.global_ruleset
    ADD CONSTRAINT global_ruleset_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY openremote.global_ruleset DROP CONSTRAINT global_ruleset_pkey;
    
   openremote            postgres    false    324            N           2606    22594    notification notification_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY openremote.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY openremote.notification DROP CONSTRAINT notification_pkey;
    
   openremote            postgres    false    328            V           2606    22625 ,   provisioning_config provisioning_config_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY openremote.provisioning_config
    ADD CONSTRAINT provisioning_config_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY openremote.provisioning_config DROP CONSTRAINT provisioning_config_pkey;
    
   openremote            postgres    false    332            P           2606    22601    syslog_event syslog_event_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY openremote.syslog_event
    ADD CONSTRAINT syslog_event_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY openremote.syslog_event DROP CONSTRAINT syslog_event_pkey;
    
   openremote            postgres    false    329            J           2606    22582 !   realm_ruleset tenant_ruleset_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY openremote.realm_ruleset
    ADD CONSTRAINT tenant_ruleset_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY openremote.realm_ruleset DROP CONSTRAINT tenant_ruleset_pkey;
    
   openremote            postgres    false    326            L           2606    22587 $   user_asset_link user_asset_link_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY openremote.user_asset_link
    ADD CONSTRAINT user_asset_link_pkey PRIMARY KEY (asset_id, realm, user_id);
 R   ALTER TABLE ONLY openremote.user_asset_link DROP CONSTRAINT user_asset_link_pkey;
    
   openremote            postgres    false    327    327    327            <           1259    21154    flyway_schema_history_s_idx    INDEX     d   CREATE INDEX flyway_schema_history_s_idx ON openremote.flyway_schema_history USING btree (success);
 3   DROP INDEX openremote.flyway_schema_history_s_idx;
    
   openremote            postgres    false    309            A           1259    22675    section_parent_id_idx    INDEX     P   CREATE INDEX section_parent_id_idx ON openremote.asset USING btree (parent_id);
 -   DROP INDEX openremote.section_parent_id_idx;
    
   openremote            postgres    false    322            B           1259    22674    section_parent_path_idx    INDEX     L   CREATE INDEX section_parent_path_idx ON openremote.asset USING gist (path);
 /   DROP INDEX openremote.section_parent_path_idx;
    
   openremote            postgres    false    322    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8            b           2620    22628    asset asset_parent_info_tgr    TRIGGER     ?   CREATE TRIGGER asset_parent_info_tgr BEFORE INSERT OR UPDATE ON openremote.asset FOR EACH ROW EXECUTE FUNCTION openremote.update_asset_parent_info();
 8   DROP TRIGGER asset_parent_info_tgr ON openremote.asset;
    
   openremote          postgres    false    322    1246            [           2606    22639 .   asset_datapoint asset_datapoint_entity_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.asset_datapoint
    ADD CONSTRAINT asset_datapoint_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES openremote.asset(id) ON DELETE CASCADE;
 \   ALTER TABLE ONLY openremote.asset_datapoint DROP CONSTRAINT asset_datapoint_entity_id_fkey;
    
   openremote          postgres    false    322    4672    323            Y           2606    22629    asset asset_parent_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.asset
    ADD CONSTRAINT asset_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES openremote.asset(id);
 H   ALTER TABLE ONLY openremote.asset DROP CONSTRAINT asset_parent_id_fkey;
    
   openremote          postgres    false    322    4672    322            Z           2606    22634    asset asset_realm_fkey    FK CONSTRAINT     y   ALTER TABLE ONLY openremote.asset
    ADD CONSTRAINT asset_realm_fkey FOREIGN KEY (realm) REFERENCES public.realm(name);
 D   ALTER TABLE ONLY openremote.asset DROP CONSTRAINT asset_realm_fkey;
    
   openremote          postgres    false    322            \           2606    22649 )   asset_ruleset asset_ruleset_asset_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.asset_ruleset
    ADD CONSTRAINT asset_ruleset_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES openremote.asset(id) ON DELETE CASCADE;
 W   ALTER TABLE ONLY openremote.asset_ruleset DROP CONSTRAINT asset_ruleset_asset_id_fkey;
    
   openremote          postgres    false    322    325    4672            a           2606    22669 2   provisioning_config provisioning_config_realm_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.provisioning_config
    ADD CONSTRAINT provisioning_config_realm_fkey FOREIGN KEY (realm) REFERENCES public.realm(name);
 `   ALTER TABLE ONLY openremote.provisioning_config DROP CONSTRAINT provisioning_config_realm_fkey;
    
   openremote          postgres    false    332            ]           2606    22644 '   realm_ruleset tenant_ruleset_realm_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.realm_ruleset
    ADD CONSTRAINT tenant_ruleset_realm_fkey FOREIGN KEY (realm) REFERENCES public.realm(name);
 U   ALTER TABLE ONLY openremote.realm_ruleset DROP CONSTRAINT tenant_ruleset_realm_fkey;
    
   openremote          postgres    false    326            _           2606    22659 -   user_asset_link user_asset_link_asset_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.user_asset_link
    ADD CONSTRAINT user_asset_link_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES openremote.asset(id) ON DELETE CASCADE;
 [   ALTER TABLE ONLY openremote.user_asset_link DROP CONSTRAINT user_asset_link_asset_id_fkey;
    
   openremote          postgres    false    322    327    4672            `           2606    22664 *   user_asset_link user_asset_link_realm_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.user_asset_link
    ADD CONSTRAINT user_asset_link_realm_fkey FOREIGN KEY (realm) REFERENCES public.realm(name) ON DELETE CASCADE;
 X   ALTER TABLE ONLY openremote.user_asset_link DROP CONSTRAINT user_asset_link_realm_fkey;
    
   openremote          postgres    false    327            ^           2606    22654 ,   user_asset_link user_asset_link_user_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY openremote.user_asset_link
    ADD CONSTRAINT user_asset_link_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_entity(id) ON DELETE CASCADE;
 Z   ALTER TABLE ONLY openremote.user_asset_link DROP CONSTRAINT user_asset_link_user_id_fkey;
    
   openremote          postgres    false    327            ?   ?  x??W[s?:~6????i??6???s%4?g:ӑm??ږ+?\&??^?|?a??3?~?~???'?????ڙ?>????K?NxC? ;M??_2ˇ???Qj`pŒ????ƾ??(??? ?&?0$C?Tݲ4핃>v C8,y???????{??0
???x?w??B6ٸ{?@?B p?C???a2|GeZ!P4n#{8?؇??`L??")ʅd]?FSV;??ѭ?e??H????·??ׯG (?D?G)?0????g,l????z?=GS?c{z??k??7??4??f???@JG??#牠?И??0???Z??'???M???ye???{?ِ
??*?*??Y?y??Vۼ"?%?%%?C|z?o?6?$?#?a??P??%m?R??.lT?е?/??s??ށ?:lǋ??K_`l?y??8??ܰ?Y\B;q?"??4>My?? 	͆fs	?#?X:'ɍ2L???y?h'????{D??oD%m?}zRon??L}?r'0Ak?Ԗ??_̮????='?'ן?*KRR
P?e|Wr??\?L&???m??c?|???1?m?rpP/ٖ?(j?:?a?ˊ?Y???o?T?9??B'?.?r??{???ڼ-E?TI6v]??R??!f?? ?{sOz??7<Ӫ?T?W??,??w? D諾a???1t??sX????,?	Ûo?|զZP??0E<c?o??????C??IٞbW????o????jK??D??p?LUeN?Y??W?zu??(??ݤӛ???N??6????w???=?gJ$.???^9???w
Zf??ڔE?????l?JG5:???T?T?}??7??T,???C?<?h????t`<|Y??[oޝ<w?K?????x?}T㚪?I?fȩڝ?)?=????l?ɏ[?.g???L?/??JD?j?u]???ٖ?S?{?S??DqLX?O96?(???Ү?vI:??&?:p6߅???Љ?nU?t?#-͔?Q?="?)?%?a̼?^~0|k5?_a???      ?      x?????? ? ?      ?      x?????? ? ?      ?      x?????? ? ?            x???Y??0ǟç@?c???-?
{?M???Vv2?8ams???^;?-+?y?8????Rp4V?|A^1?&ݛ??B?;n? ???廙P轋-N?a!?^! 최S?xm
N???m5!ף??e????91??v??k?I?SG?C?޲8e>??mkko/?w!??֊D?x??뫽????	Ӷ??N[O??????,??d?? 8ˆڋ????????zNR	ڑ???^9? ٯ??p.7,V?k????Ф??\???#??/?P?w?>G??lΒ????eƤ(?!b\'8??_ɟ=??{?-???8?ȷH 30%?P?REnr??2??J=n???(%պ)?_??%???8??????fN?Y?5!?Ct~?g??TO???XWxjB7?D^6W??D { ??}JDRVK??*g????s???$?IY?TDs3?'׳?ϡ?w?s?ٚ_&???۳??R?1?????Ǔ??ݝ???????QoPM???c9?'+?xz?ڏF?V???k      ?   ?   x?}?MK1@ϙ_Q?>%i'?vYdQ<???xZ(??c????{떽??%??%/	??6qӝ?ړh^?Bߊ???>b??fw{}???)?c????8??)̠P?mIF?^W?&#?s?րJ 9J?D?<??;x??=??? ??JWi??,K?D8dL?<?? +-Q?>m?R???s?i?<j????3qm???V9?*?u???????g&?u6?iY??R@U?dQ?$p      ?      x?????? ? ?      ?      x?????? ? ?      ?      x?????? ? ?      ?      x?????? ? ?      ?   c  x?}Q?J?@=?_!s???j[r?=?b
?ú?Mɦ??*"?-?s6[P<6??{??mǳh?ǣx6J&'?yz1I/?g???4G?7Oi\a\i
WF?@?F飜P{"?!}?????^?h????),?`%?~??QY??bl??r?=???M?h[??!(f??=c?s?Y?????V?k????q[ʊF??
p???????je?Q?=!A????d?R&???2_g????Z?+?3?@?m??md??????V??J?c??LXQ)yC????w-W5jQ???n?-?F??l??Tw????)?Q??p?`?Wب??N??w????nV?<??F9F?L??????]??B      /      x?????? ? ?      ?   ?  x??W?n?6?v??w??#?Կ ]h??zKm?vQma??r?%O??fA?}??9?L/H?f@?E???OG?0??????
m'Ğ???F?2???;?
??)3?[??|5?%???$^?I??x6V?l5?eUӔ???ق?;?Rp[??B?Z4???H?$??er9?'?b?ZL??=????G"???????'?T??J?PKe??:Y(.W??9-SAe??????3???E?N?9}???ꎕ(x?&t˩?8?{z?????8z?i????z???\W$?@8?	p??g??T"e?֍??
??IF8????H
?|?+?e?J??????nhY&?:{??d???%a?f-r?5?֕?Ҋ??Ԁ???R?R???r9???{?E?#?pwus??M???????\?hAI642&?t?"˻Cݒw[
"? ????V'cX6???Α?ب???? ???/dGLN??sN???h6jY?%?[ɪ2o????.+U???????|????p??Z??????U*8V??M??I?f?x?2{?Aֹ?餙?????:
?W??T?+z???JQ??hi????Ӊ?HU??fS5}??޸)?#!\$?%h?v??|[e,g4{~6-ɚ?e?Pu???D??Ñ?C@Ҕ
1k֜??(?&'\P???X?(?r?}?m7)??2???k?N???8?i??Q_=???ґnʒ????{V????'??0?n????/???{?͓xt???_????(DA?}ٯ????x???YZ*?_???>?v"pO??r?8/??j`?u??.??:???u??y???s??J????|=???W$
?[??{?2?$?1mB?l^;?0?3q?W?2?5T,??k?[z4???e???qN???2?ha???,;H?j$?M?P?D?aO???ͳ???m?{β^?{ ????X= ?+:^,?e?h?I??b??6uA??w@???S??Z@?=?T??????9?????????      ?   f   x????0 й?
wrI?Ӗ???&????m?\?????s????o|??ڄ?o??:~?????(4r)ޡ?0?r??IK?D)?y?4????(>??[?Z     