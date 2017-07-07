package org.llvm.openmp

import java.nio.ByteBuffer


import org.apache.spark.SparkFiles
import org.apache.spark.broadcast.Broadcast

class OmpKernel {
  @native def mappingMethod53165436(index0: Long, bound0: Long, n0: Array[Byte], n1: Array[Byte], n2: Array[Byte]) : Array[Byte]
  def mapping53165436(index0: Long, bound0: Long, n0: Array[Byte], n1: Array[Byte], n2: Array[Byte]) : Array[Byte] = {
    NativeKernels.loadOnce()
    return mappingMethod53165436(index0, bound0, n0, n1, n2)
  }

  @native def mappingMethod53165437(index0: Long, bound0: Long, n0: Array[Byte], n1: Array[Byte], n2: Array[Byte]) : Array[Byte]
  def mapping53165437(index0: Long, bound0: Long, n0: Array[Byte], n1: Array[Byte], n2: Array[Byte]) : Array[Byte] = {
    NativeKernels.loadOnce()
    return mappingMethod53165437(index0, bound0, n0, n1, n2)
  }

  @native def mappingMethod53165438(index0: Long, bound0: Long, n0: Array[Byte], n1: Array[Byte], n2: Array[Byte]) : Array[Byte]
  def mapping53165438(index0: Long, bound0: Long, n0: Array[Byte], n1: Array[Byte], n2: Array[Byte]) : Array[Byte] = {
    NativeKernels.loadOnce()
    return mappingMethod53165438(index0, bound0, n0, n1, n2)
  }

}

object OmpKernel {
  def main(args: Array[String]) {
    var i = 0 // used for loop index

    val info = new CloudInfo(args)
    val fs = new CloudFileSystem(info.fs, args(3), args(4))
    val at = AddressTable.create(fs)
    info.init(fs)

    import info.sqlContext.implicits._

    // Read each input from cloud-based filesystem
    val sizeOf___ompcloud_offload_F = at.get(5)
    val eltSizeOf___ompcloud_offload_F = 4
    var __ompcloud_offload_F = new Array[Byte](sizeOf___ompcloud_offload_F)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_F= " + sizeOf___ompcloud_offload_F)
    var __ompcloud_offload_F_bcast = info.sc.broadcast(__ompcloud_offload_F)
    val sizeOf___ompcloud_offload_E = at.get(4)
    val eltSizeOf___ompcloud_offload_E = 4
    var __ompcloud_offload_E = new Array[Byte](sizeOf___ompcloud_offload_E)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_E= " + sizeOf___ompcloud_offload_E)
    var __ompcloud_offload_E_bcast = info.sc.broadcast(__ompcloud_offload_E)
    val sizeOf___ompcloud_offload_G = at.get(6)
    val eltSizeOf___ompcloud_offload_G = 4
    var __ompcloud_offload_G = new Array[Byte](sizeOf___ompcloud_offload_G)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_G= " + sizeOf___ompcloud_offload_G)
    var __ompcloud_offload_G_bcast: Broadcast[Array[Byte]] = null
    val sizeOf___ompcloud_offload_B = at.get(1)
    val eltSizeOf___ompcloud_offload_B = 4
    var __ompcloud_offload_B = fs.read(1, sizeOf___ompcloud_offload_B)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_B= " + sizeOf___ompcloud_offload_B)
    var __ompcloud_offload_B_bcast = info.sc.broadcast(__ompcloud_offload_B)
    val sizeOf___ompcloud_offload_A = at.get(0)
    val eltSizeOf___ompcloud_offload_A = 4
    var __ompcloud_offload_A = fs.read(0, sizeOf___ompcloud_offload_A)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_A= " + sizeOf___ompcloud_offload_A)
    var __ompcloud_offload_A_bcast = info.sc.broadcast(__ompcloud_offload_A)
    val sizeOf___ompcloud_offload_D = at.get(3)
    val eltSizeOf___ompcloud_offload_D = 4
    var __ompcloud_offload_D = fs.read(3, sizeOf___ompcloud_offload_D)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_D= " + sizeOf___ompcloud_offload_D)
    var __ompcloud_offload_D_bcast = info.sc.broadcast(__ompcloud_offload_D)
    val sizeOf___ompcloud_offload_C = at.get(2)
    val eltSizeOf___ompcloud_offload_C = 4
    var __ompcloud_offload_C = fs.read(2, sizeOf___ompcloud_offload_C)
    println("XXXX DEBUG XXXX SizeOf __ompcloud_offload_C= " + sizeOf___ompcloud_offload_C)
    var __ompcloud_offload_C_bcast = info.sc.broadcast(__ompcloud_offload_C)
    val _parallelism = info.getParallelism

    // omp parallel for
    // 1 - Generate RDDs of index
    val bound_53165436_0 = 16000.toLong
    val blockSize_53165436_0 = ((bound_53165436_0).toFloat/_parallelism).floor.toLong
    val index_53165436_0 = (0.toLong to bound_53165436_0-1 by blockSize_53165436_0) // Index i
    println("XXXX DEBUG XXXX blockSize = " + blockSize_53165436_0)
    println("XXXX DEBUG XXXX bound = " + bound_53165436_0)
    val index_53165436 = index_53165436_0.map{ x => (x, __ompcloud_offload_A.slice((x.toInt * 16000) * eltSizeOf___ompcloud_offload_A, Math.min(((x.toInt + blockSize_53165436_0.toInt + 1) * 16000) * eltSizeOf___ompcloud_offload_A, sizeOf___ompcloud_offload_A)), __ompcloud_offload_E.slice((x.toInt * 16000) * eltSizeOf___ompcloud_offload_E, Math.min(((x.toInt + blockSize_53165436_0.toInt + 1) * 16000) * eltSizeOf___ompcloud_offload_E, sizeOf___ompcloud_offload_E)))}.toDS()
    // 2 - Perform Map operations
    val mapres_53165436 = index_53165436.map{ x => (x._1, new OmpKernel().mapping53165436(x._1, Math.min(x._1+blockSize_53165436_0-1, bound_53165436_0-1), __ompcloud_offload_B_bcast.value, x._2, x._3)) }
    // 3 - Merge back the results
    val __ompcloud_offload_E_tmp_53165436 = mapres_53165436.collect()
    __ompcloud_offload_E = new Array[Byte](sizeOf___ompcloud_offload_E)
    i = 0
    while (i < __ompcloud_offload_E_tmp_53165436.length) {
      __ompcloud_offload_E_tmp_53165436(i)._2.copyToArray(__ompcloud_offload_E, (__ompcloud_offload_E_tmp_53165436(i)._1.toInt * 16000) * eltSizeOf___ompcloud_offload_E)
      i += 1
    }
    __ompcloud_offload_E_bcast = info.sc.broadcast(__ompcloud_offload_E)

    // omp parallel for
    // 1 - Generate RDDs of index
    val bound_53165437_0 = 16000.toLong
    val blockSize_53165437_0 = ((bound_53165437_0).toFloat/_parallelism).floor.toLong
    val index_53165437_0 = (0.toLong to bound_53165437_0-1 by blockSize_53165437_0) // Index i
    println("XXXX DEBUG XXXX blockSize = " + blockSize_53165437_0)
    println("XXXX DEBUG XXXX bound = " + bound_53165437_0)
    val index_53165437 = index_53165437_0.map{ x => (x, __ompcloud_offload_C.slice((x.toInt * 16000) * eltSizeOf___ompcloud_offload_C, Math.min(((x.toInt + blockSize_53165437_0.toInt + 1) * 16000) * eltSizeOf___ompcloud_offload_C, sizeOf___ompcloud_offload_C)), __ompcloud_offload_F.slice((x.toInt * 16000) * eltSizeOf___ompcloud_offload_F, Math.min(((x.toInt + blockSize_53165437_0.toInt + 1) * 16000) * eltSizeOf___ompcloud_offload_F, sizeOf___ompcloud_offload_F)))}.toDS()
    // 2 - Perform Map operations
    val mapres_53165437 = index_53165437.map{ x => (x._1, new OmpKernel().mapping53165437(x._1, Math.min(x._1+blockSize_53165437_0-1, bound_53165437_0-1), __ompcloud_offload_D_bcast.value, x._2, x._3)) }
    // 3 - Merge back the results
    val __ompcloud_offload_F_tmp_53165437 = mapres_53165437.collect()
    __ompcloud_offload_F = new Array[Byte](sizeOf___ompcloud_offload_F)
    i = 0
    while (i < __ompcloud_offload_F_tmp_53165437.length) {
      __ompcloud_offload_F_tmp_53165437(i)._2.copyToArray(__ompcloud_offload_F, (__ompcloud_offload_F_tmp_53165437(i)._1.toInt * 16000) * eltSizeOf___ompcloud_offload_F)
      i += 1
    }
    __ompcloud_offload_F_bcast.destroy
    __ompcloud_offload_F_bcast = info.sc.broadcast(__ompcloud_offload_F)

    // omp parallel for
    // 1 - Generate RDDs of index
    val bound_53165438_0 = 16000.toLong
    val blockSize_53165438_0 = ((bound_53165438_0).toFloat/_parallelism).floor.toLong
    val index_53165438_0 = (0.toLong to bound_53165438_0-1 by blockSize_53165438_0) // Index i
    println("XXXX DEBUG XXXX blockSize = " + blockSize_53165438_0)
    println("XXXX DEBUG XXXX bound = " + bound_53165438_0)
    val index_53165438 = index_53165438_0.map{ x => (x, __ompcloud_offload_E.slice((x.toInt * 16000) * eltSizeOf___ompcloud_offload_E, Math.min(((x.toInt + blockSize_53165438_0.toInt + 1) * 16000) * eltSizeOf___ompcloud_offload_E, sizeOf___ompcloud_offload_E)), __ompcloud_offload_G.slice((x.toInt * 16000) * eltSizeOf___ompcloud_offload_G, Math.min(((x.toInt + blockSize_53165438_0.toInt + 1) * 16000) * eltSizeOf___ompcloud_offload_G, sizeOf___ompcloud_offload_G)))}.toDS()
    // 2 - Perform Map operations
    val mapres_53165438 = index_53165438.map{ x => (x._1, new OmpKernel().mapping53165438(x._1, Math.min(x._1+blockSize_53165438_0-1, bound_53165438_0-1), __ompcloud_offload_F_bcast.value, x._2, x._3)) }
    // 3 - Merge back the results
    val __ompcloud_offload_G_tmp_53165438 = mapres_53165438.collect()
    __ompcloud_offload_G = new Array[Byte](sizeOf___ompcloud_offload_G)
    i = 0
    while (i < __ompcloud_offload_G_tmp_53165438.length) {
      __ompcloud_offload_G_tmp_53165438(i)._2.copyToArray(__ompcloud_offload_G, (__ompcloud_offload_G_tmp_53165438(i)._1.toInt * 16000) * eltSizeOf___ompcloud_offload_G)
      i += 1
    }

    // Get the results back and write them in the HDFS
    fs.write(6, sizeOf___ompcloud_offload_G, __ompcloud_offload_G)
  }

}