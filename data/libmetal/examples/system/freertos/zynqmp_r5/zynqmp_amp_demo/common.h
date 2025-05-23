 /*
  * Copyright (c) 2017 - 2022, Xilinx Inc. and Contributors. All rights reserved.
  * Copyright (C) 2023 - 2024, Advanced Micro Devices, Inc.
  *
  * SPDX-License-Identifier: BSD-3-Clause
  */

#ifndef __COMMON_H__
#define __COMMON_H__

#include <unistd.h>
#include <stdio.h>
#include <string.h>

#include <metal/atomic.h>
#include <metal/alloc.h>
#include <metal/irq.h>
#include <metal/errno.h>
#include <metal/sys.h>
#include <metal/cpu.h>
#include <metal/io.h>
#include <metal/device.h>
#include <sys/types.h>
#include "sys_init.h"

#if defined(PLATFORM_ZYNQMP)

#define TTC0_BASE_ADDR 0xff110000
#define TTC_DEV_NAME "ff110000.ttc"
#define IPI_MASK 0x1000000

#if XPAR_CPU_ID == 0
#define IPI_DEV_NAME "ff310000.ipi"
#define IPI_BASE_ADDR 0xff310000
#define IPI_IRQ_VECT_ID 65
#else
#define IPI_DEV_NAME "ff320000.ipi"
#define IPI_BASE_ADDR 0xff320000
#define IPI_IRQ_VECT_ID 66
#endif

#elif defined(versal)
#define TTC0_BASE_ADDR 0xFF0E0000
#define IPI_BASE_ADDR 0xFF340000
#define IPI_IRQ_VECT_ID 63
#define IPI_MASK 0x0000020
#define TTC_DEV_NAME "ff0e0000.ttc"
#define IPI_DEV_NAME "ff340000.ipi"

#elif defined(VERSAL_NET)

#define TTC0_BASE_ADDR 0xFD1C0000
#define IPI_BASE_ADDR 0xEB340000
#define IPI_IRQ_VECT_ID 90
#define IPI_MASK 0x0000020
#define TTC_DEV_NAME "fd1c0000.ttc"
#define IPI_DEV_NAME "eb340000.ipi"
#endif

/* Devices names */
#define BUS_NAME        "generic"
#define SHM_DEV_NAME	"3ed80000.shm"

#define INTC_DEVICE_ID	XPAR_SCUGIC_0_DEVICE_ID
#define SHM_BASE_ADDR   0x3ED80000

/* IPI registers offset */
#define IPI_TRIG_OFFSET 0x0  /* IPI trigger reg offset */
#define IPI_OBS_OFFSET  0x4  /* IPI observation reg offset */
#define IPI_ISR_OFFSET  0x10 /* IPI interrupt status reg offset */
#define IPI_IMR_OFFSET  0x14 /* IPI interrupt mask reg offset */
#define IPI_IER_OFFSET  0x18 /* IPI interrupt enable reg offset */
#define IPI_IDR_OFFSET  0x1C /* IPI interrupt disable reg offset */

/* TTC counter offsets */
#define XTTCPS_CLK_CNTRL_OFFSET 0x0  /* TTC counter clock control reg offset */
#define XTTCPS_CNT_CNTRL_OFFSET 0xC  /* TTC counter control reg offset */
#define XTTCPS_CNT_VAL_OFFSET   0x18 /* TTC counter val reg offset */
#define XTTCPS_CNT_OFFSET(ID) ((ID) == 1 ? 0 : 1 << (ID)) /* TTC counter offset
							     ID is from 1 to 3 */

/* TTC counter control masks */
#define XTTCPS_CNT_CNTRL_RST_MASK  0x10U /* TTC counter control reset mask */
#define XTTCPS_CNT_CNTRL_DIS_MASK  0x01U /* TTC counter control disable mask */

#define LPRINTF(format, ...) \
  xil_printf("\r\nSERVER> " format, ##__VA_ARGS__)

#define LPERROR(format, ...) LPRINTF("ERROR: " format, ##__VA_ARGS__)

extern struct metal_device *ipi_dev; /* IPI metal device */
extern struct metal_device *shm_dev; /* SHM metal device */
extern struct metal_device *ttc_dev; /* TTC metal device */

/**
 * @brief   atomic_shmem_demod() - Shared memory atomic operation demo
 *          This task will:
 *          * Wait for the remote to write to shared memory.
 *          * Once it receives the notification via polling, start atomic add by
 *	      1 for 1000 times to first 32 bits of memory in the
 *	      shared memory location at 3ed00000 which is pointed to by shm_io.
 *          * Write to shared mem to notify the remote once it finishes
 *            calculation.
 *
 * @return - If setup failed, return the corresponding error number. Otherwise
 *          return 0 on success.
 */
int atomic_shmem_demod();

/**
 * @brief ipi_latency_demod() - Show performance of  IPI with Libmetal.
 *        Loop until APU tells RPU to stop via shared memory.
 *        In loop, wait for interrupt (interrupt handler stops APU to
 *        RPU timer). Then reset count on RPU to APU timer to 0, start
 *        counting and send interrupt to notify APU.
 *
 * @return - 0 on success, error code if failure.
 */
int ipi_latency_demod();

/**
 * @brief   ipi_shmem_demod() - shared memory IPI demo
 *          This task will:
 *          * Wait for IPI interrupt from the remote
 *          * Once it received the interrupt, copy the content from
 *            the ping buffer to the pong buffer.
 *          * Update the shared memory descriptor for the new available
 *            pong buffer.
 *          * Trigger IPI to notifty the remote.
 *
 * @return - 0 on success, error code if failure.
 */
int ipi_shmem_demod();

/**
 * @brief shmem_demod() - Show use of shared memory with Libmetal.
 *        Until KEEP_GOING signal is stopped, keep looping.
 *        In the loop, read message from remote, add one to message and
 *        then respond. After the loop, cleanup resources.
 *
 * @return - return 0 on success, otherwise return error number indicating
 *           type of error
 */
int shmem_demod();

/**
 * @brief shmem_latency_demod() - Show performance of shared mem.
 *        Loop until APU tells RPU to stop via shared memory.
 *        In loop, wait for interrupt (interrupt handler stops APU to
 *        RPU timer). Then reset count on RPU to APU timer to 0, start
 *        counting and send interrupt to notify APU.
 *
 * @return - 0 on success, error code if failure.
 */
int shmem_latency_demod();

/**
 * @brief shmem_throughput_demod() - Show throughput of shared mem.
 *        At signal of remote, record total time to do block read and write
 *        operation Loop until APU tells RPU to stop via shared memory.
 *        In loop, wait for interrupt (interrupt handler stops APU to
 *        RPU timer). Then reset count on RPU to APU timer to 0, start
 *        counting and send interrupt to notify APU.
 *
 * @return - 0 on success, error code if failure.
 */
int shmem_throughput_demod();

static inline void wait_for_interrupt()
{
	metal_asm volatile("wfi");
}

/**
 * @brief wait_for_notified() - Loop until notified bit
 *        in channel is set.
 *
 * @param[in] notified - pointer to the notified variable
 */
static inline void  wait_for_notified(atomic_int *notified)
{
	while (atomic_flag_test_and_set(notified));
}

/**
 * @brief print_demo() - print demo string
 *
 * @param[in] name - demo name
 */
static inline void print_demo(char *name)
{
	LPRINTF("====== libmetal demo: %s ======\n", name);
}

#endif /* __COMMON_H__ */

