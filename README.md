# PictureDel
基本说明：
  使用iOS自带的滤镜来处理图片，处理的速度不快，所以在处理中使用了多线程，项目的博客请参考我的博客http://blog.sina.com.cn/s/blog_bfb0501f0102vx1v.html，
里面有详细的说明。

将app的架构由MVC转向MVVC，会产生许多的优点，个人觉得在一下几个方面的优势比较突出。

1.把视图控制器的业务逻辑与视图展示相互隔离，试视图控制器类专门来管理视图的展示，业务逻辑单独出来在另外一个ViewModel来管理。

2.工程慢慢具体化了以后，项目中的文件会相当的多。如果遇到功能的更新，我们可以直接子类化一下ViewModel，再到视图控制器里更新一下ViewModel。如果遇到需要更换视图，可以将ViewModel重现绑定一下，不会对之前的业务逻辑产生任何影响。这也是将二则分隔开来，所带来的好处。

由此可见，花点时间来将工程的架构转化成MVVC是值得的。

在此，我们将之前的图片处理的项目进行一下转换。首先，观察一下工程下面目录，有ViewController和AppDelegate，由于没有涉及到数据结构，所以项目中暂时没有MVC中的数据Model，View在ViewController中作为一个成员属性；AppDelegate是UIApplication的代理，遵守UIApplicationDelegate协议，在这里可以将它归为项目中的其它部分。

那么，由MVC转向MVVC的首要任务也就是将ViewController解耦。这里我们创建一个继承自NSObject的子类PicViewModel，再给该类创建如下成员属性：

    @property (strong, nonatomic)  UIImageView *imageView;

    @property (strong, nonatomic)  UIBarButtonItem *picBtn;

    @property (strong, nonatomic)  UISlider *sliderVal;

    @property (strong, nonatomic)  UIButton *dealB;

    @property (strong, nonatomic)  UIPickerView *picker;

    @property (strong, nonatomic)  UIViewController *totalVc;

    @property (nonatomic,strong)   RACCommand *picCommand;

其中的视图空间要与视图控制器里的视图空间保持对应关系，RACCommand是第三方库ReactiveCocoa里面的一个类，用来发送信号，也是由MVC转向MVVC的关键属性（关于ReactiveCocoa的详细介绍，可参考我之前的博客《ReactiveCocoa一些学习摘抄》里面的一些资料）。在成员属性创建完成之后，我们可以复写一下初始化方法，把事件进行一下绑定，绑定的代码如下：

    _picCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {

        [self viewWillAppear];
            RACSignal *sig = [RACSignal createSignal:^RACDisposable *(id subscriber) {

                return nil;

            }];
      return sig;

     }];

在代码中调用[self viewWillAppear]，就相当于调用视图控制器中的-(void)viewWillAppear:(BOOL)animated方法，一些业务逻辑的关系，我们都可以添加到viewWillAppear方法之下（这是个自定义方法！！）。

完成这一步之后，ViewModel类就创建完成，接下来只需到原来的视图控制器中将视图控件与PicViewModel进行一下指向，再在视图加载方法中调用一下RACCommand成员的subscribeNext方法即可，具体代码如下：

    self.pictureVM.imageView = self.imageView;

    self.pictureVM.picBtn = self.picBtn;

    self.pictureVM.sliderVal = self.sliderVal;

    self.pictureVM.dealB = self.dealB;

    self.pictureVM.picker = self.picker;

    self.pictureVM.totalVc = self;

    

    RACSignal *sig = [self.pictureVM.picCommand execute:nil];

    

    [sig subscribeNext:^(id x) {

    }];

转型完成之后，编译工程运行。如果各个功能和操作与之前一样，那么转型成功。

其实由MVC转向MVVC步骤十分简单，但是所带来的益处是巨大的。花费一点点时间将项目改变一下架构，会非常有益于后期的开发，值得学习于借鉴。
