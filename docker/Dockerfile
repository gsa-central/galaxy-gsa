# 1.the image from bgruening/galaxy-stable
FROM bgruening/galaxy-stable

# 2.author information
MAINTAINER moralabgalaxy, moralabgalaxy@163.com

# 3.1 Set the brand as Galaxy-GSA
ENV GALAXY_CONFIG_BRAND=Galaxy-GSA
ENV GALAXY_CONFIG_DISPLAY_GALAXY_BRAND=False 

# 3.2 Set administrator account as galaxy with galaxy as password
ENV GALAXY_DEFAULT_ADMIN_USER=galaxy \
	GALAXY_DEFAULT_ADMIN_EMAIL=moralabgalaxy@163.com \
	GALAXY_DEFAULT_ADMIN_PASSWORD=galaxy \
	GALAXY_CONFIG_ADMIN_USERS=moralabgalaxy@163.com
	
# 3.3 Set to true to instruct Galaxy to look for and install missing tool dependencies before each job runs.
ENV Galaxy_CONDA_AUTO_INSTALL=True

# 4.Set the welcome page
ENV GALAXY_CONFIG_WELCOME_URL=$GALAXY_CONFIG_DIR/web/galaxy_gsa_welcome.html

# 5.Copy all Galaxy-GSA tools to the tools directory
COPY GalaxyGSA $GALAXY_ROOT/tools/GalaxyGSA
COPY GalaxyGSA $EXPORT_DIR/galaxy-central/tools/GalaxyGSA

# 6.Copy the tool_conf.xml and integrated_tool_panel.xml to the config directory
COPY galaxy_GSA_tools_config/* $GALAXY_ROOT/config/

# 7.Copy all files about welcome page to the web directory
COPY welcome_pages $GALAXY_CONFIG_DIR/web/

# 8.Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# 9.Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# 10.Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
