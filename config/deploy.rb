require 'bundler/capistrano'     #添加之后部署时会调用bundle install， 如果不需要就可以注释掉
require "capistrano/ext/multistage"     #多stage部署所需
set :stages, %w(development production)
set :default_stage, "development"
set :application, "crm_app_end"   #应用名称
set :repository,  "https://test.361way.com/svn/trunk"
set :keep_releases, 5          #只保留5个备份
set :deploy_to, "/usr/share/tomcat/webapps/#{application}"  #部署到远程机器的路径
set :user, "root"              #登录部署机器的用户名
set :password, "0acbd1238eb4"      #登录部署机器的密码， 如果不设部署时需要输入密码
default_run_options[:pty] = true          #pty: 伪登录设备
#default_run_options[:shell] = false     #Disable sh wrapping
set :use_sudo, true                            #执行的命令中含有sudo， 如果设为false， 用户所有操作都有权限
set :runner, "user2"                          #以user2用户启动服务
set :svn_username, "xxxx"
set :scm, :subversion                        #注意subversion前有冒号，不能少
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
#set :deploy_via, :copy                     #如果SCM设为空， 也可通过直接copy本地repo部署
#set :domain, "crm.abc.com"    #custom define
role :web, "192.168.0.13"                         # Your HTTP server, Apache/etc
role :app, "192.168.0.13"                          # This may be the same as your `Web` server
# role :db,  "192.168.0.13", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
#
namespace :deploy do
    desc "remove and destory this app"
    task :destory, :roles => :app do
        run "cd #{deploy_to}/../ && #{try_sudo} mv #{application} /tmp/#{application}_#{Time.now.strftime('%Y%d%m%H%M%S')}"      #try_sudo 以sudo权限执行命令
    end
    after "deploy:update", "deploy:shared:setup"              #after， before 表示在特定操作之后或之前执行其他任务
    namespace :shared do
        desc "setup shared folder symblink"
        task :setup do
            run "cd #{deploy_to}/current; rm -rf shared; ln -s #{shared_path} ."
        end
    end
    after "deploy:setup", "deploy:setup_chown"
    desc "change owner from root to user1"
    task :setup_chown do
        run "cd #{deploy_to}/../ && #{try_sudo} chown -R #{user}:#{user} #{application}"
    end
    task :start do
       run "cd #{deploy_to}/current && ./crmd.sh start"
       #try_sudo "cd #{deploy_to}/current && ./restart.sh"
    end
    task :stop do
       run "cd #{deploy_to}/current && ./crmd.sh stop"
    end
    task :restart do
       run "cd #{deploy_to}/current && ./crmd.sh restart"
    end
end
