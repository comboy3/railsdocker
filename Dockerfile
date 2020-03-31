FROM centos:7

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.7.0"
ENV rails_ver="6.0.2.1"

# 必要なパッケージをインストール
RUN yum -y update
RUN yum -y install git make autoconf curl wget vim
RUN yum -y install -y gcc-c++ openssl-devel readline-devel zlib-devel bzip2 gcc sqlite-devel
RUN yum -y install -y postgresql-devel
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash - ; yum -y install nodejs
# Yarnのインストール
RUN wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
RUN yum -y install yarn
RUN yum clean all

# rbenvのインストール
ENV rbenv_path="/usr/local/rbenv"
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
# ruby-buildのインストール
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# 初期化設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

# rubyとrailsをインストール
RUN source /etc/profile.d/rbenv.sh; rbenv install ${ruby_ver}; rbenv global ${ruby_ver}; rbenv rehash
RUN source /etc/profile.d/rbenv.sh; gem update --system; gem install -N rails; gem install bundler

# プロジェクトの作成
# 作業ディレクトリの作成、設定
RUN mkdir /rails6
##作業ディレクトリ名をAPP_ROOTに割り当てて、以下$APP_ROOTで参照
ENV RAILS6 /rails6
WORKDIR $RAILS6

# ホスト側（ローカル）のGemfileを追加する
COPY ./Gemfile $RAILS6/Gemfile
COPY ./Gemfile.lock $RAILS6/Gemfile.lock
RUN source /etc/profile.d/rbenv.sh;bundle install
COPY . /rails6

# Start the main process.
# CMD ["rails", "server", "-b", "0.0.0.0"]
