(define (make-stream-params)
  (malloc stream-params-size 'PaStreamParameters))

(define (stream-params-device stream-params)
  (c-> stream-params "PaStreamParameters device"))
(define (stream-params-channel-count stream-params)
  (c-> stream-params "PaStreamParameters channelCount"))
(define (stream-params-sample-format stream-params)
  (c-> stream-params "PaStreamParameters sampleFormat"))
(define (stream-params-suggested-latency stream-params)
  (c-> stream-params "PaStreamParameters suggestedLatency"))
(define (stream-params-post-api-specific-stream-info stream-params)
  (c-> stream-params "PaStreamParameters hostApiSpecificStreamInfo"))

(define (set-stream-params-device! stream-params value)
  (c->= stream-params "PaStreamParameters device" value))
(define (set-stream-params-channel-count! stream-params value)
  (c->= stream-params "PaStreamParameters channelCount" value))
(define (set-stream-params-sample-format! stream-params value)
  (c->= stream-params "PaStreamParameters sampleFormat" value))
(define (set-stream-params-suggested-latency! stream-params value)
  (c->= stream-params "PaStreamParameters suggestedLatency" value))
(define (set-stream-params-post-api-specific-stream-info! stream-params value)
  (c->= stream-params "PaStreamParameters hostApiSpecificStreamInfo" value))

(define (open-default-stream #!optional kappa)
  (let ((stream-pointer (malloc pointer-size '(* PaStream)))
        ;; Sync
        (stream-callback null-alien)
        (user-data null-alien))
        ;; Async
        ; (stream-callback (c-callback "PaStreamCallback"))
        ; (user-data (c-callback kappa)))
    (define err
      (c-call "Pa_OpenDefaultStream" 
        stream-pointer
        input-channel-count
        output-channel-count
        sample-format
        sample-rate
        frames-per-buffer
        stream-callback
        user-data))
    (if (> 0 err)
      (error "make-default-stream" (error-text err))
      (c-> stream-pointer "*"))))

(define (open-stream input-params output-params #!optional kappa)
  (let ((stream-pointer (malloc pointer-size '(* PaStream)))
        ;; Sync
        (stream-callback null-alien)
        (user-data null-alien))
        ;; Async
        ; (stream-callback (c-callback "PaStreamCallback"))
        ; (user-data (c-callback kappa)))
    (define err
      (c-call "Pa_OpenStream"
        stream-pointer
        input-params
        output-param
        sample-rate
        frames-per-buffer
        stream-flags
        stream-callback
        user-data))
    (if (> 0 err)
      (error "make-stream" (error-text err))
      (c-> stream-pointer "*"))))

(define (start-stream stream)
  (let ((err (c-call "Pa_StartStream" stream)))
    (if (> 0 err)
      (error "start-stream" (error-text err)))))

(define (stop-stream stream)
  (let ((err (c-call "Pa_StopStream" stream)))
    (if (> 0 err)
      (error "stop-stream" (error-text err)))))

(define (abort-stream stream)
  (let ((err (c-call "Pa_AbortStream" stream)))
    (if (> 0 err)
      (error "abort-stream" (error-text err)))))

(define (close-stream stream)
  (let ((err (c-call "Pa_CloseStream" stream)))
    (if (> 0 err)
      (error "close-stream" (error-text err)))))

(define (stream-active? stream)
  (let ((err (c-call "Pa_IsStreamActive" stream)))
    (if (> 0 err) 
      (error "stream-active?" (error-text err))
      (= 1 err))))

(define (stream-stopped? stream)
  (let ((err (c-call "Pa_IsStreamStopped" stream)))
    (if (> 0 err)
      (error "stream-stopped?" (error-text err))
      (= 1 err))))

(define (write-stream stream buffer #!optional frame-count)
  (let ((err (c-call "Pa_WriteStream" stream buffer (default frame-count frames-per-buffer))))
    (if (> 0 err) 
      (error "write-stream" (error-text err)))))

(define (read-stream stream buffer #!optional frame-count)
  (let ((err (c-call "Pa_ReadStream" stream buffer (default frame-count frames-per-buffer))))
    (if (> 0 err)
      (error "read-stream" (error-text err)))))