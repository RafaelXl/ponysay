PREFIX="/usr"
INSTALLDIR="$(DESTDIR)$(PREFIX)"


all: core truncater manpages infomanual ponythinkcompletion

core:
	sed -e 's/'\''\/usr\//'"$$(sed -e 's/'\''\//\\\//g' <<<$(PREFIX))"'\//g' <"ponysay.py" >"ponysay.py.install"

truncater:
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o "truncater" "truncater.c"

manpages:
	gzip -9 -f < "manuals/manpage.6"    > "manuals/manpage.6.gz"
	gzip -9 -f < "manuals/manpage.es.6" > "manuals/manpage.es.6.gz"

infomanual:
	makeinfo "manuals/ponysay.texinfo"
	gzip -9 -f "ponysay.info"

ponysaycompletion:
	sed -e 's/'\''\/usr\//'"$$(sed -e 's/'\''\//\\\//g' <<<$(PREFIX))"'\//g' <"completion/bash-completion.sh"   >"completion/bash-completion.sh.install"
	sed -e 's/'\''\/usr\//'"$$(sed -e 's/'\''\//\\\//g' <<<$(PREFIX))"'\//g' <"completion/fish-completion.fish" >"completion/fish-completion.fish.install"
	sed -e 's/'\''\/usr\//'"$$(sed -e 's/'\''\//\\\//g' <<<$(PREFIX))"'\//g' <"completion/zsh-completion.zsh"   >"completion/zsh-completion.zsh.install"

ponythinkcompletion: ponysaycompletion
	sed -e 's/ponysay/ponythink/g' <"completion/bash-completion.sh.install"   | sed -e 's/\/ponythink\//\/ponysay\//g' -e 's/\\\/ponythink\\\//\\\/ponysay\\\//g' >"completion/bash-completion-think.sh"
	sed -e 's/ponysay/ponythink/g' <"completion/fish-completion.fish.install" | sed -e 's/\/ponythink\//\/ponysay\//g' -e 's/\\\/ponythink\\\//\\\/ponysay\\\//g' >"completion/fish-completion-think.fish"
	sed -e 's/ponysay/ponythink/g' <"completion/zsh-completion.zsh.install"   | sed -e 's/\/ponythink\//\/ponysay\//g' -e 's/\\\/ponythink\\\//\\\/ponysay\\\//g' >"completion/zsh-completion-think.zsh"

install-min: core truncater
	mkdir -p "$(INSTALLDIR)/share/ponysay/"
	mkdir -p "$(INSTALLDIR)/share/ponysay/ponies"
	mkdir -p "$(INSTALLDIR)/share/ponysay/ttyponies"
	mkdir -p "$(INSTALLDIR)/share/ponysay/quotes"
	cp -P    ponies/*.pony "$(INSTALLDIR)/share/ponysay/ponies/"
	cp -P ttyponies/*.pony "$(INSTALLDIR)/share/ponysay/ttyponies/"
	cp -P    quotes/*.*    "$(INSTALLDIR)/share/ponysay/quotes/"

	mkdir -p             "$(INSTALLDIR)/bin/"
	install "ponysay"    "$(INSTALLDIR)/bin/ponysay"
	install "ponysay.py" "$(INSTALLDIR)/bin/ponysay.py"
	ln -sf  "ponysay"    "$(INSTALLDIR)/bin/ponythink"

	mkdir   -p                 "$(INSTALLDIR)/lib/ponysay/"
	install -s "truncater"     "$(INSTALLDIR)/lib/ponysay/truncater"

	mkdir -p          "$(INSTALLDIR)/share/licenses/ponysay/"
	install "COPYING" "$(INSTALLDIR)/share/licenses/ponysay/COPYING"

install-bash: ponythinkcompletion
	mkdir -p                                        "$(INSTALLDIR)/share/bash-completion/completions/"
	install "completion/bash-completion.sh.install" "$(INSTALLDIR)/share/bash-completion/completions/ponysay"
	install "completion/bash-completion-think.sh"   "$(INSTALLDIR)/share/bash-completion/completions/ponythink"

install-zsh: ponythinkcompletion
	mkdir -p                                        "$(INSTALLDIR)/share/zsh/site-functions/"
	install "completion/zsh-completion.zsh.install" "$(INSTALLDIR)/share/zsh/site-functions/_ponysay"
	install "completion/zsh-completion-think.zsh"   "$(INSTALLDIR)/share/zsh/site-functions/_ponythink"

install-fish: ponythinkcompletion
	mkdir -p                                          "$(INSTALLDIR)/share/fish/completions/"
	install "completion/fish-completion.fish.install" "$(INSTALLDIR)/share/fish/completions/ponysay.fish"
	install "completion/fish-completion-think.fish"   "$(INSTALLDIR)/share/fish/completions/ponythink.fish"

install-man: manpages
	mkdir -p                       "$(INSTALLDIR)/share/man/man6"
	install "manuals/manpage.6.gz" "$(INSTALLDIR)/share/man/man6/ponysay.6.gz"
	ln -sf  "ponysay.6.gz"         "$(INSTALLDIR)/share/man/man6/ponythink.6.gz"

install-man-es: manpages
	mkdir -p                          "$(INSTALLDIR)/share/man/es/man6"
	install "manuals/manpage.es.6.gz" "$(INSTALLDIR)/share/man/es/man6/ponysay.6.gz"
	ln -sf  "ponysay.6.gz"            "$(INSTALLDIR)/share/man/es/man6/ponythink.6.gz"

install-info: infomanual
	mkdir -p                  "$(INSTALLDIR)/share/info"
	install "ponysay.info.gz" "$(INSTALLDIR)/share/info/ponysay.info.gz"
	install "ponysay.info.gz" "$(INSTALLDIR)/share/info/ponythink.info.gz"
	install-info --dir-file="$(INSTALLDIR)/share/info/dir" --entry="Miscellaneous" --description="My Little Ponies for your terminal" "$(INSTALLDIR)/share/info/ponysay.info.gz"
	install-info --dir-file="$(INSTALLDIR)/share/info/dir" --entry="Miscellaneous" --description="My Little Ponies for your terminal" "$(INSTALLDIR)/share/info/ponythink.info.gz"

install-no-info: install-min install-bash install-zsh install-fish install-man install-man-es

install-pdf:
	install "ponysay.pdf" "$(INSTALLDIR)/doc/ponysay.pdf"

install: install-no-info install-info
	@echo -e '\n\n'\
'/--------------------------------------------------\\\n'\
'|   ___                                            |\n'\
'|  / (_)        o                                  |\n'\
'|  \__   _  _      __                              |\n'\
'|  /    / |/ |  | /  \_|   |                       |\n'\
'|  \___/  |  |_/|/\__/  \_/|/                      |\n'\
'|              /|         /|                       |\n'\
'|              \|         \|                       |\n'\
'|   ____                                           |\n'\
'|  |  _ \  ___   _ __   _   _  ___   __ _  _   _   |\n'\
'|  | |_) |/ _ \ | '\''_ \ | | | |/ __| / _` || | | |  |\n'\
'|  |  __/| (_) || | | || |_| |\__ \| (_| || |_| |  |\n'\
'|  |_|    \___/ |_| |_| \__, ||___/ \__,_| \__, |  |\n'\
'|                       |___/              |___/   |\n'\
'\\--------------------------------------------------/'
	@echo '' | ./ponysay -f ./`if [[ "$$TERM" = "linux" ]]; then echo ttyponies; else echo ponies; fi`/pinkiecannon.pony | tail --lines=30 ; echo -e '\n'

uninstall:
	if [ -d "$(INSTALLDIR)/share/ponysay" ]; then                                rm -fr "$(INSTALLDIR)/share/ponysay"                              ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay"  ]; then                                 rm -fr "$(INSTALLDIR)/lib/ponysay"                                ; fi
	if [ -f "$(INSTALLDIR)/bin/ponysay" ]; then                                  unlink "$(INSTALLDIR)/bin/ponysay"                                ; fi
	if [ -f "$(INSTALLDIR)/bin/ponythink" ]; then                                unlink "$(INSTALLDIR)/bin/ponythink"                              ; fi
	if [ -f "$(INSTALLDIR)/share/licenses/ponysay/COPYING" ]; then               unlink "$(INSTALLDIR)/share/licenses/ponysay/COPYING"             ; fi
	if [ -f "$(INSTALLDIR)/share/bash-completion/completions/ponysay" ]; then    unlink "$(INSTALLDIR)/share/bash-completion/completions/ponysay"  ; fi
	if [ -f "$(INSTALLDIR)/share/bash-completion/completions/ponythink" ]; then  unlink "$(INSTALLDIR)/share/bash-completion/completions/ponythink"; fi
	if [ -f "$(INSTALLDIR)/share/fish/completions/ponysay.fish" ]; then          unlink "$(INSTALLDIR)/share/fish/completions/ponysay.fish"        ; fi
	if [ -f "$(INSTALLDIR)/share/fish/completions/ponythink.fish" ]; then        unlink "$(INSTALLDIR)/share/fish/completions/ponythink.fish"      ; fi
	if [ -f "$(INSTALLDIR)/share/zsh/site-functions/_ponysay"; ]; then           unlink "$(INSTALLDIR)/share/zsh/site-functions/_ponysay"          ; fi
	if [ -f "$(INSTALLDIR)/share/zsh/site-functions/_ponythink"; ]; then         unlink "$(INSTALLDIR)/share/zsh/site-functions/_ponythink"        ; fi
	if [ -f "$(INSTALLDIR)/share/man/man6/ponysay.6.gz" ]; then                  unlink "$(INSTALLDIR)/share/man/man6/ponysay.6.gz"                ; fi
	if [ -f "$(INSTALLDIR)/share/man/man6/ponythink.6.gz" ]; then                unlink "$(INSTALLDIR)/share/man/man6/ponythink.6.gz"              ; fi
	if [ -f "$(INSTALLDIR)/share/man/es/man6/ponysay.6.gz" ]; then               unlink "$(INSTALLDIR)/share/man/es/man6/ponysay.6.gz"             ; fi
	if [ -f "$(INSTALLDIR)/share/man/es/man6/ponythink.6.gz" ]; then             unlink "$(INSTALLDIR)/share/man/es/man6/ponythink.6.gz"           ; fi
	if [ -f "$(INSTALLDIR)/share/info/ponysay.info.gz" ]; then                   unlink "$(INSTALLDIR)/share/info/ponysay.info.gz"                 ; fi
	if [ -f "$(INSTALLDIR)/share/info/ponythink.info.gz" ]; then                 unlink "$(INSTALLDIR)/share/info/ponythink.info.gz"               ; fi
	if [ -f "$(INSTALLDIR)/doc/ponysay.pdf" ]; then                              unlink "$(INSTALLDIR)/doc/ponysay.pdf"                            ; fi

uninstall-old:
	if [ -d "$(INSTALLDIR)/share/ponies" ]; then                                 rm -fr "$(INSTALLDIR)/share/ponies"                               ; fi
	if [ -d "$(INSTALLDIR)/share/ttyponies" ]; then                              rm -fr "$(INSTALLDIR)/share/ttyponies"                            ; fi
	if [ -f "$(INSTALLDIR)/bin/ponysaytruncater" ]; then                         unlink "$(INSTALLDIR)/bin/ponysaytruncater"                       ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay/link.pl"  ]; then                         unlink "$(INSTALLDIR)/lib/ponysay/link.pl"                        ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay/linklist.pl"  ]; then                     unlink "$(INSTALLDIR)/lib/ponysay/linklist.pl"                    ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay/pq4ps"  ]; then                           unlink "$(INSTALLDIR)/lib/ponysay/pq4ps"                          ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay/pq4ps.pl"  ]; then                        unlink "$(INSTALLDIR)/lib/ponysay/pq4ps.pl"                       ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay/pq4ps-list"  ]; then                      unlink "$(INSTALLDIR)/lib/ponysay/pq4ps-list"                     ; fi
	if [ -d "$(INSTALLDIR)/lib/ponysay/pq4ps-list.pl"  ]; then                   unlink "$(INSTALLDIR)/lib/ponysay/pq4ps-list.pl"                  ; fi

clean:
	if [ -f "truncater" ]; then                                rm -f "truncater"                              ; fi
	if [ -f "completion/bash-completion-think.sh" ]; then      rm -f "completion/bash-completion-think.sh"    ; fi
	if [ -f "completion/fish-completion-think.fish" ]; then    rm -f "completion/fish-completion-think.fish"  ; fi
	if [ -f "completion/zsh-completion-think.zsh" ]; then      rm -f "completion/zsh-completion-think.zsh"    ; fi
	if [ -f "completion/bash-completion.sh.install" ]; then    rm -f "completion/bash-completion.sh.install"  ; fi
	if [ -f "completion/fish-completion.fish.install" ]; then  rm -f "completion/fish-completion.fish.install"; fi
	if [ -f "completion/zsh-completion.zsh.install" ]; then    rm -f "completion/zsh-completion.zsh.install"  ; fi
	if [ -f "manuals/manpage.6.gz" ]; then                     rm -f "manuals/manpage.6.gz"                   ; fi
	if [ -f "manuals/manpage.es.6.gz" ]; then                  rm -f "manuals/manpage.es.6.gz"                ; fi
	if [ -f "ponysay.info.gz"  ]; then                         rm -f "ponysay.info.gz"                        ; fi
	if [ -f "ponysay.py.install" ]; then                       rm -f "ponysay.py.install"                     ; fi

clean-old:
	if [ -f "ponysaytruncater" ]; then  rm -f "ponysaytruncater"; fi


## Scripts for maintainers

ttyponies:
	mkdir -p "ttyponies"
	for pony in $$(ls --color=no "ponies/"); do                                                    \
	    echo "building ttypony: $$pony"                                                           ;\
	    if [ `readlink "ponies/$$pony"` = "" ]; then                                               \
	        ponysay2ttyponysay < "ponies/$$pony" | tty2colourfultty -c 1 -e > "ttyponies/$$pony"  ;\
		git add "ttyponies/$$pony"                                                            ;\
	    elif [ ! -f "ttyponies/$$pony" ]; then                                                     \
	        ln -s `readlink "ponies/$$pony"` "ttyponies/$$pony"                                   ;\
		git add "ttyponies/$$pony"                                                            ;\
	    fi                                                                                         \
	done

pdfmanual:
	texi2pdf "manuals/ponysay.texinfo"
	git add  "manuals/ponysay.texinfo" "ponysay.pdf"
	for ext in `echo aux cp cps fn ky log pg toc tp vr`; do              \
	    (if [ -f "ponysay.$$ext" ]; then unlink "ponysay.$$ext"; fi);    \
	done
	if [ -d "ponysay.t2d" ]; then rm -r "ponysay.t2d"; fi

submodules: clean
	(cd "ponyquotes4ponysay/"; make clean)
	git submodule init
	git submodule update

quotes: submodules
	(cd "ponyquotes4ponysay/"; make -B)
	if [ -d quotes ]; then git rm "quotes/"*.*; fi
	mkdir -p "quotes"
	cp "ponyquotes4ponysay/ponyquotes/"*.* "quotes"
	git add "quotes/"*.*

