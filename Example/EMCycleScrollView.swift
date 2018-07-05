//
//  EMCycleScrollView.swift
//  Example
//  轮播图控件
//  Created by Illusion on 2018/6/16.
//  Copyright © 2017年 Illusion. All rights reserved.
//

import SDWebImage

class EMCycleScrollView: UIView, UIScrollViewDelegate {
    var timeInterval: TimeInterval = 1
    
    private var imageUrls: [String] = [String]()
    private var imageArray: [UIImageView] = [UIImageView]()
    private var tapAction: (Int) -> Void
    private var currentIndex: Int = 0
    private weak var timer: Timer?
    
    private lazy var scrollNode: UIScrollView = {
        let node = UIScrollView()
        node.scrollsToTop = false
        node.isPagingEnabled = true
        node.bounces = false
        node.frame = self.bounds
        node.delegate = self
        node.showsHorizontalScrollIndicator = false
        node.decelerationRate = 1
        node.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
        node.contentSize = CGSize(width: self.frame.size.width * 3.0, height: 0)
        return node
    }()
    
    lazy var pageControl: EMPageControl = {
        let node = EMPageControl(frame: CGRect(x: 15, y: Int(self.frame.height - 15), width: 10 * self.imageUrls.count , height: 10))
        node.numberOfPages = self.imageUrls.count
        return node
    }()
    
    // MARK: - Public
    func resetCurrentPage(_ page: Int) {
        currentIndex = page
        pageControl.currentPage = page
        resetImageView()
        startTimer()
    }
    
    // MARK: - Init
    init(frame: CGRect, imageUrls: [String], tapAction action: @escaping(Int) -> Void) {
        self.imageUrls = imageUrls
        self.tapAction = action
        super.init(frame: frame)
        
        addImageView()
        addSubview(scrollNode)
        addSubview(pageControl)
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        // 设置图片信息
        if contentOffsetX == 2 * scrollView.frame.width {// 左滑
            currentIndex = getActualCurrentPage(calculatedPage: currentIndex + 1)
            resetImageView()
        } else if (contentOffsetX == 0) {// 右滑
            currentIndex = getActualCurrentPage(calculatedPage: currentIndex - 1)
            resetImageView()
        }

        // 设置 pageControl
        if contentOffsetX < scrollView.frame.width && contentOffsetX > 0 {
            if contentOffsetX <= scrollView.frame.width * 0.5 {
                pageControl.currentPage = getActualCurrentPage(calculatedPage: currentIndex - 1)
            } else if contentOffsetX > scrollView.frame.width * 0.5 {
                pageControl.currentPage = getActualCurrentPage(calculatedPage: currentIndex)
            }
        } else if contentOffsetX > scrollView.frame.width && contentOffsetX < scrollView.frame.width * 2 {
            if contentOffsetX >= scrollView.frame.width * 1.5 {
                pageControl.currentPage = getActualCurrentPage(calculatedPage: currentIndex + 1)
            } else if contentOffsetX < scrollView.frame.width * 1.5 {
                pageControl.currentPage = currentIndex
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: true)
        startTimer()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Action
    @objc fileprivate func cycleViewDidClick(gesture: UITapGestureRecognizer) {
        print("点击了第\(currentIndex)张图")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.sd_setImage(with: URL(string: imageUrls[currentIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        tapAction(currentIndex)
    }
    
    @objc fileprivate func autoScroll() {
        if imageUrls.count < 2 {
            return
        }
        scrollNode.setContentOffset(CGPoint(x: self.frame.width * 2, y: 0), animated: true)
    }
    
    func startTimer() {
        guard imageUrls.count > 0 else { return }
        
        if let myTimer = timer {
            myTimer.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func addImageView() {
        var x: CGFloat = 0
        var pageIndex: NSInteger = self.imageUrls.count - 1
        for index in 0..<3 {
            let imgNode = UIImageView()
            x = CGFloat(index) * frame.width
            imgNode.frame = CGRect(x: x, y: 0, width: frame.width, height: frame.height)
            imgNode.sd_setImage(with: URL(string: imageUrls.count == 0 ? "" : (imageUrls[pageIndex])), placeholderImage: nil, options: [.refreshCached, .retryFailed])
            imgNode.contentMode = .scaleAspectFill
            imgNode.clipsToBounds = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(cycleViewDidClick(gesture:)))
            imgNode.addGestureRecognizer(gesture)
            imgNode.isUserInteractionEnabled = true
            imageArray.append(imgNode)
            scrollNode.addSubview(imgNode)
            
            if imageUrls.count == 1 {
                pageIndex = 0
                scrollNode.isScrollEnabled = false
            } else {
                pageIndex = index == 0 ? 0 : 1
            }
        }
        
    }
    
    fileprivate func resetImageView(){
        
        let preIndex: NSInteger = getActualCurrentPage(calculatedPage: currentIndex - 1)
        let nextIndex: NSInteger = getActualCurrentPage(calculatedPage: currentIndex + 1)
        
        if imageUrls.count == 0 {
            return
        }

        imageArray[0].sd_setImage(with: URL(string: imageUrls[preIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        imageArray[1].sd_setImage(with: URL(string: imageUrls[currentIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        imageArray[2].sd_setImage(with: URL(string: imageUrls[nextIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        
        scrollNode.contentOffset = CGPoint(x: self.frame.width, y: 0)// 这里不可以使用setcontentOffset:animate的方法，否则滑动过快会出现bug
    }
    
    /// 根据下一页的计算值获取实际下一页的值
    ///
    /// - Parameter page: 通过+1或-1得到的下一页的值
    /// - Returns: 实际值
    fileprivate func getActualCurrentPage(calculatedPage page: NSInteger) -> NSInteger {
        if page == imageUrls.count {
            return 0
        } else if page == -1 {
            return imageUrls.count - 1
        } else {
            return page
        }
    }
}
