--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    ip inet,
    filename character varying,
    size integer,
    referer_id integer,
    user_agent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: dumped_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dumped_files (
    id integer NOT NULL,
    accessed_at timestamp without time zone,
    file_frozen boolean DEFAULT false,
    filename character varying,
    size integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_hash bytea
);


--
-- Name: dumped_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dumped_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dumped_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dumped_files_id_seq OWNED BY dumped_files.id;


--
-- Name: file_freezes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE file_freezes (
    id integer NOT NULL,
    filename character varying,
    size integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_freezes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_freezes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_freezes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_freezes_id_seq OWNED BY file_freezes.id;


--
-- Name: frozen_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE frozen_files (
    id integer NOT NULL,
    file_id character varying,
    dumped_file_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: frozen_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE frozen_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: frozen_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE frozen_files_id_seq OWNED BY frozen_files.id;


--
-- Name: referers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE referers (
    id integer NOT NULL,
    referer_string text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: referers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE referers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE referers_id_seq OWNED BY referers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: simple_captcha_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simple_captcha_data (
    id integer NOT NULL,
    key character varying(40),
    value character varying(6),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simple_captcha_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simple_captcha_data_id_seq OWNED BY simple_captcha_data.id;


--
-- Name: thaw_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE thaw_requests (
    id integer NOT NULL,
    filename character varying,
    size integer,
    referer_id integer,
    user_agent_id integer,
    ip inet,
    finished boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thaw_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE thaw_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thaw_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE thaw_requests_id_seq OWNED BY thaw_requests.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uploads (
    id integer NOT NULL,
    ip inet,
    filename character varying,
    size integer,
    user_agent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_agents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_agents (
    id integer NOT NULL,
    user_agent_string text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_agents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_agents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_agents_id_seq OWNED BY user_agents.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dumped_files ALTER COLUMN id SET DEFAULT nextval('dumped_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_freezes ALTER COLUMN id SET DEFAULT nextval('file_freezes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY frozen_files ALTER COLUMN id SET DEFAULT nextval('frozen_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY referers ALTER COLUMN id SET DEFAULT nextval('referers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simple_captcha_data ALTER COLUMN id SET DEFAULT nextval('simple_captcha_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY thaw_requests ALTER COLUMN id SET DEFAULT nextval('thaw_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_agents ALTER COLUMN id SET DEFAULT nextval('user_agents_id_seq'::regclass);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: dumped_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dumped_files
    ADD CONSTRAINT dumped_files_pkey PRIMARY KEY (id);


--
-- Name: file_freezes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file_freezes
    ADD CONSTRAINT file_freezes_pkey PRIMARY KEY (id);


--
-- Name: frozen_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY frozen_files
    ADD CONSTRAINT frozen_files_pkey PRIMARY KEY (id);


--
-- Name: referers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY referers
    ADD CONSTRAINT referers_pkey PRIMARY KEY (id);


--
-- Name: simple_captcha_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simple_captcha_data
    ADD CONSTRAINT simple_captcha_data_pkey PRIMARY KEY (id);


--
-- Name: thaw_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY thaw_requests
    ADD CONSTRAINT thaw_requests_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_agent_string_constraint; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agent_string_constraint UNIQUE (user_agent_string);


--
-- Name: user_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: idx_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_key ON simple_captcha_data USING btree (key);


--
-- Name: index_downloads_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_downloads_on_filename ON downloads USING btree (filename);


--
-- Name: index_downloads_on_ip; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_downloads_on_ip ON downloads USING btree (ip);


--
-- Name: index_downloads_on_referer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_downloads_on_referer_id ON downloads USING btree (referer_id);


--
-- Name: index_downloads_on_user_agent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_downloads_on_user_agent_id ON downloads USING btree (user_agent_id);


--
-- Name: index_dumped_files_on_accessed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dumped_files_on_accessed_at ON dumped_files USING btree (accessed_at);


--
-- Name: index_dumped_files_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_dumped_files_on_filename ON dumped_files USING btree (filename);


--
-- Name: index_dumped_files_on_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dumped_files_on_size ON dumped_files USING btree (size);


--
-- Name: index_file_freezes_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_file_freezes_on_filename ON file_freezes USING btree (filename);


--
-- Name: index_file_freezes_on_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_file_freezes_on_size ON file_freezes USING btree (size);


--
-- Name: index_frozen_files_on_dumped_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_frozen_files_on_dumped_file_id ON frozen_files USING btree (dumped_file_id);


--
-- Name: index_referers_on_referer_string; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_referers_on_referer_string ON referers USING btree (md5(referer_string));


--
-- Name: index_thaw_requests_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thaw_requests_on_filename ON thaw_requests USING btree (filename);


--
-- Name: index_thaw_requests_on_ip; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thaw_requests_on_ip ON thaw_requests USING btree (ip);


--
-- Name: index_thaw_requests_on_referer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thaw_requests_on_referer_id ON thaw_requests USING btree (referer_id);


--
-- Name: index_thaw_requests_on_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thaw_requests_on_size ON thaw_requests USING btree (size);


--
-- Name: index_thaw_requests_on_user_agent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thaw_requests_on_user_agent_id ON thaw_requests USING btree (user_agent_id);


--
-- Name: index_uploads_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_uploads_on_created_at ON uploads USING btree (created_at);


--
-- Name: index_uploads_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_uploads_on_filename ON uploads USING btree (filename);


--
-- Name: index_uploads_on_ip; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_uploads_on_ip ON uploads USING btree (ip);


--
-- Name: index_uploads_on_user_agent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_uploads_on_user_agent_id ON uploads USING btree (user_agent_id);


--
-- Name: index_user_agents_on_user_agent_string; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_agents_on_user_agent_string ON user_agents USING btree (md5(user_agent_string));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20160416173957');

INSERT INTO schema_migrations (version) VALUES ('20160416175306');

INSERT INTO schema_migrations (version) VALUES ('20160416180032');

INSERT INTO schema_migrations (version) VALUES ('20160416180254');

INSERT INTO schema_migrations (version) VALUES ('20160421221446');

INSERT INTO schema_migrations (version) VALUES ('20160424122732');

INSERT INTO schema_migrations (version) VALUES ('20160424154303');

INSERT INTO schema_migrations (version) VALUES ('20160424203047');

INSERT INTO schema_migrations (version) VALUES ('20160426192505');

INSERT INTO schema_migrations (version) VALUES ('20160427225729');

INSERT INTO schema_migrations (version) VALUES ('20160509170355');

INSERT INTO schema_migrations (version) VALUES ('20160509171748');

INSERT INTO schema_migrations (version) VALUES ('20160509192134');

