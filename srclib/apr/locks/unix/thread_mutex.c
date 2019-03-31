/* Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "apr_arch_thread_mutex.h"
#define APR_WANT_MEMFUNC
#include "apr_want.h"

#ifdef FIBER_THREAD
    #include "../libfiber/fiber_manager.h"
#endif

#if APR_HAS_THREADS

static apr_status_t thread_mutex_cleanup(void *data)
{
    apr_thread_mutex_t *mutex = data;
    apr_status_t rv;
#ifdef FIBER_THREAD
    rv = (fiber_mutex_destroy((fiber_mutex_t*)&mutex->mutex) == FIBER_SUCCESS) ? APR_SUCCESS : APR_ENOLOCK;
#else
    rv = pthread_mutex_destroy(&mutex->mutex);
#endif

#ifdef HAVE_ZOS_PTHREADS
    if (rv) {
        rv = errno;
    }
#endif

    return rv;
} 

APR_DECLARE(apr_status_t) apr_thread_mutex_create(apr_thread_mutex_t **mutex,
                                                  unsigned int flags,
                                                  apr_pool_t *pool)
{
    apr_thread_mutex_t *new_mutex;
    apr_status_t rv;
    
#ifndef HAVE_PTHREAD_MUTEX_RECURSIVE
    if (flags & APR_THREAD_MUTEX_NESTED) {
        return APR_ENOTIMPL;
    }
#endif

    new_mutex = apr_pcalloc(pool, sizeof(apr_thread_mutex_t));
    new_mutex->pool = pool;

#ifdef FIBER_THREAD
    rv = (fiber_mutex_init((fiber_mutex_t*)&new_mutex->mutex) == FIBER_SUCCESS) ? APR_SUCCESS : APR_ENOLOCK;
#else
    #ifdef HAVE_PTHREAD_MUTEX_RECURSIVE
        if (flags & APR_THREAD_MUTEX_NESTED) {
            pthread_mutexattr_t mattr;
            
            rv = pthread_mutexattr_init(&mattr);
            if (rv) return rv;
            
            rv = pthread_mutexattr_settype(&mattr, PTHREAD_MUTEX_RECURSIVE);
            if (rv) {
                pthread_mutexattr_destroy(&mattr);
                return rv;
            }
            
            rv = pthread_mutex_init(&new_mutex->mutex, &mattr);
            
            pthread_mutexattr_destroy(&mattr);
        } else
    #endif
        rv = pthread_mutex_init(&new_mutex->mutex, NULL);
#endif

    if (rv) {
#ifdef HAVE_ZOS_PTHREADS
        rv = errno;
#endif
        return rv;
    }

    apr_pool_cleanup_register(new_mutex->pool,
                              new_mutex, thread_mutex_cleanup,
                              apr_pool_cleanup_null);

    *mutex = new_mutex;
    return APR_SUCCESS;
}

APR_DECLARE(apr_status_t) apr_thread_mutex_lock(apr_thread_mutex_t *mutex)
{
    apr_status_t rv;
    
#ifdef FIBER_THREAD
    rv = (fiber_mutex_lock((fiber_mutex_t*)&mutex->mutex) == FIBER_SUCCESS) ? APR_SUCCESS : APR_ENOLOCK;
#else
    rv = pthread_mutex_lock(&mutex->mutex);
#endif

#ifdef HAVE_ZOS_PTHREADS
    if (rv) {
        rv = errno;
    }
#endif
        
    return rv;
}

APR_DECLARE(apr_status_t) apr_thread_mutex_trylock(apr_thread_mutex_t *mutex)
{
    apr_status_t rv;
#ifdef FIBER_THREAD
    rv = (fiber_mutex_trylock((fiber_mutex_t*)&mutex->mutex) == FIBER_SUCCESS) ? APR_SUCCESS : APR_ENOLOCK;
#else
    rv = pthread_mutex_trylock(&mutex->mutex);
#endif

    if (rv) {
#ifdef HAVE_ZOS_PTHREADS
        rv = errno;
#endif
        return (rv == EBUSY) ? APR_EBUSY : rv;
    }

    return APR_SUCCESS;
}

APR_DECLARE(apr_status_t) apr_thread_mutex_unlock(apr_thread_mutex_t *mutex)
{
    apr_status_t status;
#ifdef FIBER_THREAD
    status = (fiber_mutex_unlock((fiber_mutex_t*)&mutex->mutex) == FIBER_SUCCESS) ? APR_SUCCESS : APR_ENOLOCK;
#else
    status = pthread_mutex_unlock(&mutex->mutex);
#endif

#ifdef HAVE_ZOS_PTHREADS
    if (status) {
        status = errno;
    }
#endif

    return status;
}

APR_DECLARE(apr_status_t) apr_thread_mutex_destroy(apr_thread_mutex_t *mutex)
{
    return apr_pool_cleanup_run(mutex->pool, mutex, thread_mutex_cleanup);
}

APR_POOL_IMPLEMENT_ACCESSOR(thread_mutex)

#endif /* APR_HAS_THREADS */
