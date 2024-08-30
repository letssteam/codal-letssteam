.ONESHELL:

# Réportoire de départ du build
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Definitions des groupes de dépôts
CODAL_TARGETS := codal-stm32-DISCO_L475VG_IOT codal-stm32-PNUCLEO_WB55RG codal-stm32-STEAM32_WB55RG
CODAL_LIBRARIES := codal-core codal-stm32
CODAL := codal
DEFAULT_CODAL_TARGET := codal-stm32-STEAM32_WB55RG

# Références aux dépôts pour clonage et mise à jour
REPOS = $(CODAL) $(CODAL_LIBRARIES) $(CODAL_TARGETS)
BASE_URL := https://github.com/letssteam

# Macros utilitaires pour la gestion des fichiers et répertoires
define _remove_file_if_exist
	if [ -f $1 ] ; then 
		echo "Remove $1" 
		rm -f $1
	fi
endef

define _remove_directory_if_exist
	if [ -d $1 ] ; then 
		echo "Remove directory $1" 
		rm -Rf $1
	fi
endef

# Macro pour la création du fichier codal.json d'une cible Codal spécifique
define _configuring_current_codal_target
	echo "Configuring $(1) as current target"

	# Création du fichier de configuration codal.json
	
	REPO_NAME="$(strip $(1))"
	REPO_PATH="codal/libraries/$$REPO_NAME"
	REPO_URL="$(BASE_URL)/$$REPO_NAME"

	echo \
	"{
	\"target\": {
		\"name\": \"$$REPO_NAME\", 
		\"url\": \"$$REPO_URL\",
		\"branch\": \"main\",
		\"type\": \"git\",
		\"dev\": true
	}
	}" > codal/codal.json
endef

define _build_current_codal_target
	if [ -f $(CODAL)/codal.json ]; then
		echo "Building current target"
		cd $(CODAL) 
		./build.py -d
	else
		echo "$(CODAL)/codal.json does not exist ! Impossible to build"
		exit 1
	fi
endef

# Macro pour la construction d'une cible Codal spécifique
define _build_codal_target
	# Nettoyage des anciens fichiers de configuration et exemples
	$(call _remove_directory_if_exist,codal/samples)
	$(call _remove_directory_if_exist,codal/source)
	$(call _remove_file_if_exist,codal/codal.json)

	# Création du fichier de configuration codal.json
	$(call _configuring_current_codal_target, $1)

	# Lancer la construction
	$(call _build_current_codal_target)

endef

define _configuring_default_codal_target
	if [ ! -f $@ ]; then
		echo "Configuring the default target: $(DEFAULT_CODAL_TARGET)"
		$(call _configuring_current_codal_target, $(DEFAULT_CODAL_TARGET))
	fi
endef

# Cible de build de la cible actuelle (si aucune n'est définie c'est la cible par défaut qui sera construite)
.PHONY: build
build: $(CODAL) $(CODAL)/codal.json
	@$(call _build_current_codal_target)

# Génère codal.json uniquement si le fichier n'existe pas déjà 
$(CODAL)/codal.json:
	@$(call _configuring_default_codal_target)

# Création des cibles de build pour chaque target de Codal
define _build_codal_target_template
.PHONY: build_$(1)
build_$(1): $(if $(filter codal,$1),codal,codal/libraries/$1)
	@$$(call _build_codal_target,$$(strip $$(subst build_,,$$@)))

endef

$(foreach target,$(CODAL_TARGETS),$(eval $(call _build_codal_target_template,$(target))))

# Build toutes les cibles
.PHONY:build_all
build_all: |$(foreach target,$(CODAL_TARGETS),build_$(target))

# Tagging des cibles après build
define _tag_codal_target_template
.PHONY: tag_$(1)
tag_$(1): build_$(1)
	@cd $(CODAL)
	./build.py -l

endef

$(foreach target,$(CODAL_TARGETS),$(eval $(call _tag_codal_target_template,$(target))))

.PHONY:tag_all
tag_all: |$(foreach target,$(CODAL_TARGETS),tag_$(target))

# Pull des dépôts pour les mettre à jour
define _pull_repo
	REPO_DIR=$(if $(filter codal,$1),codal,codal/libraries/$1)
	cd $$REPO_DIR
	git pull --ff-only origin main
	cd $(ROOT_DIR)

endef

# Macro de définition des cibles de pull pour chaque dépôt
define _pull_codal_repo_template
.PHONY: pull_$(1)
pull_$(1):$(if $(filter codal,$1),codal,codal/libraries/$1)
	@$$(call _pull_repo,$(1))

endef

$(foreach repo,$(REPOS),$(eval $(call _pull_codal_repo_template,$(repo))))

.PHONY:pull_all
pull_all: |$(foreach repo,$(REPOS),pull_$(repo))

# Clonage des dépôts
define _clone_repo
	REPO_DIR=$(if $(filter codal,$1),codal,codal/libraries/$1)
	if [ -d "$$REPO_DIR" ]; then
		echo "Repository $1 already cloned in $$REPO_DIR"
	else
		echo "Cloning repository $1..."
		git clone -j8 $(BASE_URL)/$1.git $$REPO_DIR
	fi

endef

# Cibles de clonage pour chaque dépôt
define _clone_codal_repo_template
.PHONY: clone_$(1)
clone_$(1):$(if $(filter codal,$(1)),codal,codal/libraries/$(1))

$(if $(filter codal,$(1)),codal,codal/libraries/$(1)):
	@$$(call _clone_repo,$(1))

endef

$(foreach repo,$(REPOS),$(eval $(call _clone_codal_repo_template,$(repo))))

.PHONY:clone_all
clone_all: $(foreach repo,$(REPOS),clone_$(repo))

# Nettoyage des builds et fichiers temporaires
define _clean
	$(call _remove_directory_if_exist,codal/build)
	$(call _remove_directory_if_exist,codal/samples)
	$(call _remove_directory_if_exist,codal/source)
	$(call _remove_file_if_exist,codal/codal.json)

endef

.PHONY: clean
clean:
	@$(call _clean)

# Vérification de l'état des dépôts pour garantir qu'il n'y a pas de modifications non commitées
define _check_git_repository_is_clean
	REPO_DIR=$(if $(filter codal,$1),codal,$(if $(filter-out codal,$1),$1,codal/libraries/$1))
	
	if [ -d $$REPO_DIR ] ; then 
		echo "Entering $$REPO_DIR"
		cd $$REPO_DIR

		git update-index -q --ignore-submodules --refresh

		if ! git diff-files --quiet --ignore-submodules; then
			echo "There are uncommitted changes in the repository $$REPO_DIR"
			exit 1
		fi
		
		if ! git diff-index --cached --quiet --ignore-submodules HEAD --; then
			echo "There are uncommitted changes in the repository $$REPO_DIR"
			exit 1
		fi

		cd $(ROOT_DIR)
	else
		echo "$$REPO_DIR is not a directory"
		exit 1
	fi

endef

# Macro pour vérifier tous les dépôts
define _check_git_repositories_are_clean
	$(foreach repo,$(REPOS), $(call _check_git_repository_is_clean,$(repo)))

endef

.PHONY:check-git-clean
check-git-clean:
	@$(call _check_git_repositories_are_clean)

# Nettoyage complet avec vérification préalable de l'état des dépôts
.PHONY: deepclean
deepclean:check-git-clean
	@$(call _remove_directory_if_exist,codal)

# Setup général incluant le nettoyage et le clonage
.PHONY : all
all : setup

.PHONY : setup
setup : |clean clone_all
	
# Affiche toutes les cibles disponibles dans le Makefile
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

