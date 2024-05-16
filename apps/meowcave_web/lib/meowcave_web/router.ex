defmodule MeowCaveWeb.Router do
  use MeowCaveWeb, :router
  # 在这里重新的写一下吧，上面的宏干了两件事儿：
  #
  # * use Phoenix.Router, helpers: false
  # 其中 pipeline 和 scope 是这里实现的。
  #
  # * 导入了一系列的模块与函数

  # 一个被叫做 `plug` 的原子与一个 `do` 语句块被输入
  # pipeline 宏里，后面的看不懂
  pipeline :browser do
    # 这里的 plug 可以等同于 Plug 的。
    # 这个的逻辑很简单，先通过 expand_plug_and_opts/3 将其变成
    # {plug, opts}
    # 之后直接丢进对应 Router 的 @phoenix_pipeline 里
    # 也就是说，这里所有的原子都对应着同名的函数。
    plug :accepts, ["html"]
    # accepts/2 来自 Phoenix.Controller
    plug :fetch_session
    # fetch_session/2 来自 Plug.Conn
    plug :fetch_live_flash
    # fetch_live_flash/2 来自 Phoenix.LiveView.Router
    plug :put_root_layout, html: {MeowCaveWeb.Layouts, :root}
    # put_root_layout/2 来自 Phoenix.Controller
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # 我其实是想让不用的情况走不同的 pipeline
  pipeline :guest do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MeowCaveWeb.PlainLayouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    # 加上鉴权相关
  end

  scope "/", MeowCaveWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about", PageController, :about
    # get "/gellary", GellaryController

    ## 保留一个登录的窗口
    # ...
    ## 计划设计的路由

    ## 页面
    # 首页（经过认证的）
    # get "/" MeowPageController, :index
    # 关于
    # get "/about" MeowPageController, :about
    # 使用方法
    # get "/guide", MeowPageController, :overview
    # get "/guide/:page", MeowPageController, :guide
    # 使用许可
    # get "/policy/:page", MeowPageController, :policy

    ## 鉴权与用户
    # 登录注册与注销
    # get "/login", AccountController, :login_with_session
    # get "/signup", AccountController, :signup
    # get "/logout", AccountController, :logout_session
    # 用户主页
    # get "/u/:user", UserController, :other
    # get "/me", UserController, :me
    # 邀请
    # get "/invite", InvitationController, :show
    # get "/invite/create", InvitationController, :create
    # 关注
    # get "/me/following", UserCollections, :following
    # get "/me/followers", UserCollections, :followers
    # get "/u/:user/following", UserCollections, :following
    # get "/u/:user/followers", UserCollections, :followers

    ## 内容
    # 圈子
    # get "/t/:topic", TopicController, :access
    # get "/t/create", TopicController, :create
    # get "/t/:topic/edit", TopicController, :edit
    # 帖子
    # get "/p/:post", PostController, :access
    # get "/p/create", PostController, :create
    # get "/p/:post/idx/:index", PostController, :start_from
    # 另一种格式是 "/p/:post?idx=:idx?range=:range / until=:until"
    # 动态
    # get "/f/create", FeedController, :create
    # get "/f/:feed", FeedController, :access
    # 收藏夹
    # get "/c/:collect", ColleactionController, :access
    # get "/c/new", ColleactionController, :create
    # 评论
    # TODO: 等到其它系统设计完成

    ## MeowCave 的特色功能
    # 冷冻
    # get "/me/freeze", AccountController, :freeze
    # 批量导出
    # get "/me/export", ExportController, :user
    # get "/p/:post/export", ExportController, :post
    # get "/f/:feed/export", ExportController, :feed
    # get "/c/:collect/export", ExportController, :collections
    # 岁月史书
    # get "/l/:event", RocorderController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", MeowCaveWeb do
  #   pipe_through :api
  # end

  # 在开发环境下启用 LiveDashboard 以及 Swoosh 邮箱的预览
  if Application.compile_env(:meowcave_web, :dev_routes) do
    # 如果你想要在生产环境下使用 LiveDashboard ，你需要将其放在鉴权后并且
    # 仅允许管理员予以访问。如果你的应用还没有仅管理员可进的部分，你可以使用
    # Plug.BasicAuth 以实现最基本的认证，与此同时，你也需要使用 SSL
    # （这需要你自己做）。
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MeowCaveWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
