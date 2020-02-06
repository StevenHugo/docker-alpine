FROM alpine:latest

RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/main" >> /etc/apk/repositories \
&& echo "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/community" >> /etc/apk/repositories \
&& echo "https://mirror.tuna.tsinghua.edu.cn/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --no-cache update && apk --no-cache upgrade
RUN apk add --no-cache bash git vim gnupg make

WORKDIR /usr/share/

# git
RUN git config --global alias.co checkout
RUN git config --global alias.br branch
RUN git config --global alias.ci commit
RUN git config --global alias.st status
RUN git config --global alias.unstage 'reset HEAD --'
RUN git config --global alias.last 'log -1 HEAD'
RUN git config --global alias.visual '!gitk'
RUN git config --global alias.all '!f() { ls -R -d */.git | sed 's,\/.git,,' | xargs -P10 -I{} git -C {} $1;  }; f'
RUN git config --global core.editor vim

# environmnet configuration
RUN echo "" >> ~/.bashrc
RUN echo "# custom" >> ~/.bashrc
RUN echo "## alias" >> ~/.bashrc
RUN echo "alias cp='cp -i'" >> ~/.bashrc
RUN echo "alias mv='mv -i'" >> ~/.bashrc
RUN echo "alias rm='rm -i'" >> ~/.bashrc
RUN echo "alias shred='shred -u -z -n 9'" >> ~/.bashrc

## Put a blank space (Hit spacebar from the keyboard) before any command. The command will not be recorded in history.
RUN export HISTCONTROL=ignorespace

## Automatically clear history at logout.
RUN echo "Automatically clear history at logout" >> ~/.bashrc
RUN echo "unset HISTFILE" >> ~/.bashrc

# vim configuration
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
RUN sh ~/.vim_runtime/install_awesome_vimrc.sh

# git-secret
RUN git clone https://github.com/sobolevn/git-secret /usr/share/git-secret
WORKDIR /usr/share/git-secret/
RUN make build
RUN PREFIX="/usr/local" make install
WORKDIR /usr/share/
RUN find git-secret/ -type f -print0 | xargs -0 -I {} shred -uf {}
RUN rm -rf git-secret
## gwak (required by git-secret)
RUN apk add --no-cache gawk

# remove unusual software
RUN apk del --no-cache make

CMD ["/usr/bin/bash"]
