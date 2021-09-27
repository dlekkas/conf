readonly VIMRC=~/.config/nvim/init.vim
readonly VIM_DIR=~/.config/nvim
readonly COC_SETTINGS_JSON=$VIM_DIR/coc-settings.json
readonly COC_SETTINGS_VIMRC=$VIM_DIR/coc-settings.vimrc
readonly ZSHRC=~/.zshrc
readonly TMUXCONF=~/.tmux.conf
readonly TIMESTAMP=$(date "+%y-%m-%d-%H-%M")
readonly LOCAL_INSTALL_DIR=$HOME/.local

BASEDIR=$(dirname $(realpath "$0"))

VIM_CONF_FILE=${BASEDIR}/init.vim
ZSH_CONF_FILE=${BASEDIR}/zshrc
TMUX_CONF_FILE=${BASEDIR}/tmux.conf

CMAKE_VERSION=3.20.5
TMUX_VERSION=3.2

# Install autoconf, automake and pkg-config since everything needs those
mkdir -p $LOCAL_INSTALL_DIR/opt

export PATH=$HOME/.local/bin:$PATH

echo "Checking and installing cmake"
if ! command -v cmake &>/dev/null; then
	# install prerequisites
	sudo apt install libssl-dev
	# download source zip file
	wget -qO /tmp/cmake-${CMAKE_VERSION}.tar.gz \
		https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz
	tar -xf /tmp/cmake-${CMAKE_VERSION}.tar.gz -C ${LOCAL_INSTALL_DIR}/opt
	# build from source and install to custom location
	pushd ${LOCAL_INSTALL_DIR}/opt/cmake-${CMAKE_VERSION}
	./bootstrap --prefix=${LOCAL_INSTALL_DIR} && make && make install
	popd
fi


echo "Checking and installing neovim"
if ! command -v nvim &>/dev/null; then
	# install prerequisites
	sudo apt install gettext libtool libtool-bin autoconf automake pkg-config unzip curl
	# clone neovim repo
	git clone -b stable https://github.com/neovim/neovim ${LOCAL_INSTALL_DIR}/opt/neovim
	# build from source and install to custom location
	pushd ${LOCAL_INSTALL_DIR}/opt/neovim
	make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${LOCAL_INSTALL_DIR} && make install
	popd

	mkdir -p $HOME/.config/nvim
fi


echo "Setting up neovim config file..."
#if [ -f $VIMRC ]; then
if ! diff -I '^"' ${VIM_CONF_FILE} ${VIMRC}; then
  old_vimrc="$VIMRC.$TIMESTAMP"
  cp $VIMRC $old_vimrc
  echo "\"old vimrc backed up to $old_vimrc" > $VIMRC
  cat $VIM_CONF_FILE >> $VIMRC
fi



echo "Checking and installing rust"
# install rust in a non-interactive manner
if ! command -v rustc && ! command -v ~/.cargo/bin/rustc; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# install ripgrep tool
echo "Checking and installing ripgrep..."
command -v rg &>/dev/null || ~/.cargo/bin/cargo install ripgrep

# install nodejs which is used by coc.vim
echo "Checking and installing nodejs..."
if ! command -v node &> /dev/null; then
	# fetch and unzip latest version of nodejs
	wget -qO /tmp/node-latest.tar.gz http://nodejs.org/dist/node-latest.tar.gz
	tar -xf /tmp/node-latest.tar.gz -C ${LOCAL_INSTALL_DIR}/opt

	# build from source and install to custom location
	pushd `ls -rd ${LOCAL_INSTALL_DIR}/opt/node-v*`
	./configure --prefix=${LOCAL_INSTALL_DIR} && make && make install
	popd
fi

echo "Checking and installing Ninja..."
if ! command -v ninja &> /dev/null; then
	git clone -b release git://github.com/ninja-build/ninja.git \
			${LOCAL_INSTALL_DIR}/opt/ninja
	pushd ${LOCAL_INSTALL_DIR}/opt/ninja
	cmake -Bbuild-cmake -H. && cmake --build build-cmake
	cp build-cmake/ninja ${LOCAL_INSTALL_DIR}/bin
	popd
fi

# needed for ccls
# TODO(dimlek): check whether Clang+LLVM is installed
echo "Checking and installing Clang+LLVM..."
if ! command -v clang && ! command -v ${LOCAL_INSTALL_DIR}/opt/llvm-project/Release/bin/clang; then
	LLVM_VERSION=12.0.0
	git clone -b llvmorg-${LLVM_VERSION} https://github.com/llvm/llvm-project.git \
			${LOCAL_INSTALL_DIR}/opt/llvm-project
	pushd ${LOCAL_INSTALL_DIR}/opt/llvm-project
	cmake -Hllvm -BRelease -G Ninja -DCMAKE_BUILD_TYPE=Release \
				-DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_PROJECTS=clang \
				-DCMAKE_INSTALL_PREFIX=${LOCAL_INSTALL_DIR}
	ninja -C Release clangFormat clangFrontendTool clangIndex clangTooling clang
	popd
fi


echo "Checking and installing ccls..."
if ! command -v ccls &> /dev/null; then
	git clone --depth=1 --recursive https://github.com/MaskRay/ccls \
			${LOCAL_INSTALL_DIR}/opt/ccls
	pushd ${LOCAL_INSTALL_DIR}/opt/ccls
	LLVM_DIR=${LOCAL_INSTALL_DIR}/opt/llvm-project/Release
	cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_PREFIX_PATH="$LLVM_DIR" \
				-DCMAKE_INSTALL_PREFIX=${LOCAL_INSTALL_DIR}
	cmake --build Release --target install
	popd
fi

cat <<EOF >$COC_SETTINGS_JSON
{
  "suggest.autoTrigger": "always",
  "suggest.triggerCompletionWait": "300",
  "coc.preferences.useQuickfixForLocations": true,
  "languageserver": {
    "ccls": {
      "command": "ccls",
      "filetypes": ["c", "cpp", "cuda", "objc", "objcpp"],
      "rootPatterns": [".ccls-root", "compile_commands.json"],
      "initializationOptions": {
        "cache": {
          "directory": ".ccls-cache"
        },
        "client": {
          "snippetSupport": true
        }
      }
    }
  }
}
EOF

# (optional) install bear (used to generate compile_commands.json file)
if ! command -v bear &>/dev/null; then
	sudo apt install libfmt-dev libspdlog-dev
	sudo apt install libgrpc++-dev protobuf-compiler-grpc
	git clone https://github.com/rizsotto/Bear.git ${LOCAL_INSTALL_DIR}/opt/bear
	mkdir ${LOCAL_INSTALL_DIR}/opt/bear/build
	pushd ${LOCAL_INSTALL_DIR}/opt/bear/build
	cmake -DENABLE_UNIT_TESTS=OFF -DENABLE_FUNC_TESTS=OFF \
				-DCMAKE_INSTALL_PREFIX=${LOCAL_INSTALL_DIR} ../
	popd

# install pip3
if ! command -v pip3 &>/dev/null; then
	wget -qO /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
	python3 /tmp/get-pip.py
fi

# install cpplint [https://github.com/cpplint/cpplint]
echo "Checking and installing cpplint..."
if ! command -v ccls &>/dev/null; then
	pip3 install --user cpplint
fi


echo "Checking and installing tmux..."
if ! command -v tmux &>/dev/null; then
	# install prerequisites (libevent, ncurses and yacc)
	sudo apt install libevent-dev libncurses5-dev libncursesw5-dev byacc

	git clone -b ${TMUX_VERSION} https://github.com/tmux/tmux.git \
							 ${LOCAL_INSTALL_DIR}/opt/tmux
	# build from source and install to custom location
	pushd ${LOCAL_INSTALL_DIR}/opt/tmux
	sh ./autogen.sh
	./configure --prefix=${LOCAL_INSTALL_DIR} && make && make install
	popd
fi

echo "Checking and installing TPM (Tmux Plugin Manager)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Setting up tmux config file..."
if ! diff -I '^"' ${TMUX_CONF_FILE} ${TMUXCONF}; then
	if [ -f ${TMUXCONF} ]; then
		old_tmuxconf="$TMUXCONF.$TIMESTAMP"
		cp $TMUXCONF $old_tmuxconf
		echo "# old tmux.conf backed up to $old_tmuxconf" > $TMUXCONF
	fi
  cat $TMUX_CONF_FILE >> $TMUXCONF
fi

# TODO(): Install ranger and also set image preview mode if supported

echo "Checking and installing zsh..."
if ! command -v zsh &>/dev/null; then
	# TODO(): check whether there are any prerequisites to install
	ZSH_VERSION=5.8
	wget -qO /tmp/zsh-${ZSH_VERSION}.tar.xz \
		https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz/download
	tar -xf /tmp/zsh-${ZSH_VERSION}.tar.xz -C ${LOCAL_INSTALL_DIR}/opt

	# build from source and install to custom location
	pushd ${LOCAL_INSTALL_DIR}/opt/zsh-${ZSH_VERSION}
	./configure --prefix=${LOCAL_INSTALL_DIR} && make && make install
	popd

	# useful if we can't use `chsh` to change shell which means that the shell is
	# not contained in `/etc/shells`
	# TODO(dimlek): offer an alternative to change the shell
	echo '[ -f $HOME/.local/bin/zsh ] && exec $HOME/.local/bin/zsh -l' >> $HOME/.profile
fi


echo "Installing fzf..."
if ! command -v fzf &>/dev/null; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi


echo "Installing ohmyzsh ..."
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc --unattended
if ! grep -q "^\s*source \$ZSH/oh-my-zsh.sh" $ZSHRC; then
  cat <<EOF >>$ZSHRC

# use ohmyzsh
export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git fzf)
source \$HOME/.aliases
source \$ZSH/oh-my-zsh.sh
EOF

fi

# fzf config set-up
if ! grep -q "^\s*export FZF_DEFAULT_COMMAND" $ZSHRC; then
  cat <<EOF >>$ZSHRC

if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi
EOF

fi


# (optional) download linux kernel locally
# git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
# cd linux-stable
# git checkout <version>
